//
//  MainViewController.swift
//  enClose
//
//  Created by Erfan Reed
//

// Import necessary libraries
import UIKit
import AVFoundation
@preconcurrency import WebKit

enum TargetWebView {
    case main
    case external
}

// Define a ViewController class that inherits from UIViewController
class MainViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {

    /* A boolean flag for enabling debug mode
       
       IMPORTANT: set to false for production or users can inspect your web views.
     
    */
    static let debugMode = true
    
    // Declare the first webpage to be loaded
    var index: String = "index"
    // Declare if external URLs should open in Safari
    let openExternalURLsInSafari = true;
    // Declare a WKWebView property
	var webView: WKWebView!

    // Custom initializer to override the default value if needed
    init(index: String = "index") {
       self.index = index
       super.init(nibName: nil, bundle: nil)
    }
    
    // Required initializer for decoding
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
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
		webView.scrollView.bounces = false
        webView.backgroundColor = .black
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
		// Enable the web inspector for Safari when in debug mode iOS 16.4+
        if #available(iOS 16.4, *) {
            if (MainViewController.debugMode == true) {
                webView.isInspectable = true
            }
        } else {
            // Fallback on earlier versions
        }

		view = webView
	}

    // Override the viewDidLoad() function to load the initial web page
	override func viewDidLoad() {
		super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: self.index, withExtension: "html", subdirectory: "www") {
			webView.loadFileURL(url, allowingReadAccessTo: url)
			let request = URLRequest(url: url)
			webView.load(request)
		}

        // Add observers for external display notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplayConnected(_:)), name: .externalDisplayConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplayDisconnected(_:)), name: .externalDisplayDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplayWebViewFinishedLoading(_:)), name: .externalDisplayWebViewFinishedLoading, object: nil)
	}

    // Function to disable user text selection via JavaScript
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let javaScriptConstants = """
            const __DEBUG_MODE__ = \(MainViewController.debugMode);
            const __DEVICE_NAME__ = '\(UIDevice.current.name)';
            const __DEVICE_MODEL__ = '\(UIDevice.current.model)';
            const __DEVICE_SYSTEM_NAME__ = '\(UIDevice.current.systemName)';
            const __DEVICE_SYSTEM_VERSION__ = '\(UIDevice.current.systemVersion)';
            """
        evaluateJavascript(javaScript: javaScriptConstants)

        let javascriptStyle = """
            var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}';
            var head = document.head || document.getElementsByTagName('head')[0];
            var style = document.createElement('style');
            style.type = 'text/css';
            style.appendChild(document.createTextNode(css));
            head.appendChild(style);
            """
        evaluateJavascript(javaScript: javascriptStyle)
    }

    // Function to handle messages received from JavaScript
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        // A string to store parameters received from JavaScript messages
        var iosParameters = ""
        // A dictionary to store query string parameters from JavaScript messages
        var queryStringDictionary = [String: String]()

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

            // Check if debug mode is enabled and print information
            if(MainViewController.debugMode == true) {
                // Print the original request and the queryStringDictionary
                print("Attempting to call native method: \(iosMethod)")
                print(String(data: try! JSONSerialization.data(withJSONObject: queryStringDictionary, options: .prettyPrinted), encoding: .utf8)!)
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
            UIApplication.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }
    
    // This function evaluates javascript on the main webview
    func evaluateJavascript(javaScript: String, target: TargetWebView = .main) {
        // Execute javascript on the main web view
        if (target == .main) {
            if (MainViewController.debugMode == true) {
                print("Evaluating Javascript (main):\n>_ \(javaScript)")
            }
            webView.evaluateJavaScript(javaScript, completionHandler: nil)
        }
        
        // Execute javascript on the external display web view (if available)
        if (target == .external) {
            guard let externalDisplayWebView = ExternalDisplayViewController.sharedWebView else { return }

            if (MainViewController.debugMode == true) {
                print("Evaluating Javascript (external display):\n>_ \(javaScript)")
            }
            externalDisplayWebView.evaluateJavaScript(javaScript, completionHandler: nil)
        }
    }
    
    // Function to be called when external display is connected
    @objc func handleExternalDisplayConnected(_ notification: Notification) {
        if (MainViewController.debugMode == true) {
            print("External display connected.")
        }
        evaluateJavascript(javaScript: """
            var __EXTERNAL_DISPLAY__ = true;
            enCloseEvent('externalDisplayConnected');            
            """
        )
    }

    // Function to be called when external display is disconnected
    @objc func handleExternalDisplayDisconnected(_ notification: Notification) {
        if (MainViewController.debugMode == true) {
            print("External display disconnected")
        }
        evaluateJavascript(javaScript: """
            var __EXTERNAL_DISPLAY__ = false;
            enCloseEvent('externalDisplayDisconnected');
            """
        )
    }

    // Function to be called when external display is disconnected
    @objc func handleExternalDisplayWebViewFinishedLoading(_ notification: Notification) {
        if (MainViewController.debugMode == true) {
            print("External display web view finished loading")
        }
        evaluateJavascript(javaScript: """
            enCloseEvent('externalDisplayWebViewFinishedLoading');
            """
        )
    }

    // Function to handle memory warnings
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    // Function to auto hide home indicator bar
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    // Function to specify whether the status bar is hidden
	override var prefersStatusBarHidden: Bool {
		return true
	}

    // A custom "Hello, World!" function which is called from Javascript, that demonstrates how to perform a javascript call back after perfoming native operations
	@objc func helloWorld(_ params: [String: String]) {
        var javaScript: String = ""
        
        // Play a tweet sound
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound(systemSoundID)
        
		// process nativeCall successCallback function and send data to web UI
		let successResponse = "You have successfully called a native function from javascript, congratulations!"
		if let successCallback = params["successCallback"] {
			javaScript = "\(successCallback)('\(successResponse)');"
		}
        evaluateJavascript(javaScript: javaScript)
	}
    
    // A custom "updateExternalDisplayMessage" function which is called from Javascript, that demostrates how to update an HTML element on external display from the native code
    @objc func updateExternalDisplayMessage(_ params: [String: String]) {
        var javaScript: String = ""
        
        let message = params["message"] ?? ""
        javaScript = "document.querySelector('.prompt').innerText = '\(message)';"
        evaluateJavascript(javaScript: javaScript, target: .external)
    }

}
