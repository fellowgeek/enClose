//
//  ViewController.swift
//  enClose
//
//  Created by Erfan Reed
//

// Import necessary libraries
import UIKit
import WebKit
import AVFoundation

// Define a ViewController class that inherits from UIViewController
class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {

    // A dictionary to store query string parameters from JavaScript messages
	var queryStringDictionary = [String: String]()
    // A string to store parameters received from JavaScript messages
	var iosParameters = ""
    // A boolean flag for enabling debug mode
	let debugMode = true
    // Declare a WKWebView property
	var webView: WKWebView!

    // Override the loadView() function to create and configure the WKWebView
	override func loadView() {
		
		let contentController = WKUserContentController()
		contentController.add(self, name: "enClose")
		
		let webConfiguration = WKWebViewConfiguration()
		webConfiguration.userContentController = contentController
		
		webView = WKWebView(frame: .zero, configuration: webConfiguration)
		webView.uiDelegate = self
		webView.navigationDelegate = self
		webView.scrollView.bounces = false
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
				perform(selector)
			}

            // Check if debug mode is enabled
			if(debugMode == true) {
                // Print the original request and the queryStringDictionary
				print("request: \(request)")
				print("queryStringDictionary: \(queryStringDictionary)")
			}
			
		}
		
	}

    // Function to handle memory warnings
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    // Function to specify whether the status bar is hidden
	override var prefersStatusBarHidden: Bool {
		return true
	}

    // A custom "Hello, World!" function which is called from Javascript, it plays a system sound when invoked
	let helloWorldSelector = #selector(helloWorld)
	@objc func helloWorld() {
	
		// play a system sound
	    AudioServicesPlaySystemSound(1005)


		// process nativeCall successCallback function and send data to web UI
		let successResponse = "You have successfully called a native function from javascript, and you got schwifty!"
		
		var javaScript: String = ""
		if let successCallback = queryStringDictionary["successCallback"] {
			javaScript = "\(successCallback)('\(successResponse)');"
		}
		webView.evaluateJavaScript(javaScript, completionHandler: nil)
		
	}
	
}
