//
//  ViewController.swift
//  enClose-MacOS
//
//  Created by Erfan Reed
//

// Import necessary libraries
import Cocoa
@preconcurrency import WebKit

// Define a ViewController class that inherits from NSViewController
class ViewController: NSViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {

    // A dictionary to store query string parameters from JavaScript messages
	var queryStringDictionary = [String: String]()
    // A string to store parameters received from JavaScript messages
    var iosParameters = ""
    // A boolean flag for enabling debug mode
    let debugMode = true
	// Declare if external URLs should open in Safari
    let openExternalURLsInSafari = true;
    // Declare a WKWebView property
	var webView: WKWebView!

    // Override the loadView() function to create and configure the WKWebView
	override func loadView() {
        super.loadView()
        
		let contentController = WKUserContentController()
		contentController.add(self, name: "enClose")

		let webConfiguration = WKWebViewConfiguration()
		webConfiguration.userContentController = contentController

		webView = WKWebView(frame: .zero, configuration: webConfiguration)
		webView.uiDelegate = self
		webView.navigationDelegate = self
        webView.underPageBackgroundColor = .black
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
            webView.isInspectable = true
        }
		view = webView

	}

    // Override the viewDidLoad() function to load the initial web page
	override func viewDidLoad() {
		super.viewDidLoad()

		if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www") {
			webView.loadFileURL(url, allowingReadAccessTo: url)
			let request = URLRequest(url: url)
			webView.load(request)
		}

	}

    // Function to disable user text selection via JavaScript
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		let javascriptStyle = "var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}'; var head = document.head || document.getElementsByTagName('head')[0]; var style = document.createElement('style'); style.type = 'text/css'; style.appendChild(document.createTextNode(css)); head.appendChild(style);"
		webView.evaluateJavaScript(javascriptStyle, completionHandler: nil)
	}

    // Function to handle messages received from JavaScript
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        // Check if the message body is a string
		guard let request = message.body as? String else { return }

        // Check if the request starts with "ios:"
		if(request.hasPrefix("ios:") == true) {

            // Extract and process the method name and parameters from the request
			var range: NSRange
            // Find the range from the start of the string to the first "?" character
			range = NSRange(location: 0, length: Int((request as NSString).range(of: "?").location))
            // Extract the method name from the request and remove "ios:"
			var iosMethod = (request as NSString).substring(with: range)
			iosMethod = iosMethod.replacingOccurrences(of: "ios:", with: "")
            // Find the range from the character after the first "?" to the end of the string
			range = NSRange(location: Int((request as NSString).range(of: "?").location) + 1, length: (request.count - Int((request as NSString).range(of: "?").location)) - 1)
			iosParameters = (request as NSString).substring(with: range)

            // Initialize an empty dictionary to store key-value pairs
			queryStringDictionary.removeAll()

            // Split the parameters into key-value pairs
			let urlComponents = iosParameters.components(separatedBy: "&")
			for keyValuePair: String in urlComponents {
				let pairComponents = keyValuePair.components(separatedBy: "=")
				let key = pairComponents.first?.removingPercentEncoding
				let value = pairComponents.last?.removingPercentEncoding
                // Add key-value pairs to the dictionary
				queryStringDictionary[key ?? ""] = value
			}

            // Convert the method name into a selector
			let selector = NSSelectorFromString(iosMethod)
            // Check if the current object responds to the selector
			if(responds(to: selector) == true) {
                // If it does, perform the method
                perform(selector, with: queryStringDictionary)
            } else {
                print("Unable to find @objc method for selector: \(selector)")
            }
            // Check if debug mode is enabled
			if(debugMode == true) {
				print("request: \(request)")
                // Print the original request and the queryStringDictionary
				print("queryStringDictionary: \(queryStringDictionary)")
			}
		}
	}

    // Handle opening of the external URLs
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if openExternalURLsInSafari && (url.scheme == "http" || url.scheme == "https") {
            decisionHandler(.cancel)
            NSWorkspace.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }

    // This function evaluates javascript on the main webview
    func evaluateJavascript(javaScript: String) {
        if (debugMode == true) {
            print("Evaluating Javascript: \(javaScript)")
        }
        webView.evaluateJavaScript(javaScript, completionHandler: nil)
    }
    
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

    // A custom "Hello, World!" function which is called from Javascript, it speaks a message
	@objc func helloWorld(_ params: [String: String]) {

		let synthesizer = NSSpeechSynthesizer()
		synthesizer.startSpeaking(params["message"] ?? "")

		// process nativeCall successCallback function and send data to web UI
		let successResponse = "You have successfully called a native function from javascript, and you got schwifty!"

		var javaScript: String = ""
		if let successCallback = params["successCallback"] {
			javaScript = "\(successCallback)('\(successResponse)');"
		}
        evaluateJavascript(javaScript: javaScript)
	}

}
