//
//  ViewController.swift
//  enClose-MacOS
//
//  Created by Erfan Reed on 9/16/18.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {

	var queryStringDictionary = [String: String]()
	var iosParameters = ""
	let debugMode = true
	
	var webView: WKWebView!
	
	override func loadView() {
		
		let contentController = WKUserContentController()
		contentController.add(self, name: "enClose")
		
		let webConfiguration = WKWebViewConfiguration()
		webConfiguration.userContentController = contentController
		
		webView = WKWebView(frame: .zero, configuration: webConfiguration)
		webView.uiDelegate = self
		webView.navigationDelegate = self
		view = webView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www") {
			webView.loadFileURL(url, allowingReadAccessTo: url)
			let request = URLRequest(url: url)
			webView.load(request)
		}
		
	}
	
	// disable user text selection
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		let javascriptStyle = "var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}'; var head = document.head || document.getElementsByTagName('head')[0]; var style = document.createElement('style'); style.type = 'text/css'; style.appendChild(document.createTextNode(css)); head.appendChild(style);"
		webView.evaluateJavaScript(javascriptStyle, completionHandler: nil)
	}
	
	// enclose
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		
		guard let requestURL = message.body as? String else { return }
		
		if(requestURL.hasPrefix("ios:") == true) {
			
			// call the native method if exists
			var range: NSRange
			range = NSRange(location: 0, length: Int((requestURL as NSString).range(of: "?").location))
			var iosMethod = (requestURL as NSString).substring(with: range)
			iosMethod = iosMethod.replacingOccurrences(of: "ios:", with: "")
			
			range = NSRange(location: Int((requestURL as NSString).range(of: "?").location) + 1, length: (requestURL.count - Int((requestURL as NSString).range(of: "?").location)) - 1)
			iosParameters = (requestURL as NSString).substring(with: range)
			
			queryStringDictionary.removeAll()
			let urlComponents = iosParameters.components(separatedBy: "&")
			for keyValuePair: String in urlComponents {
				let pairComponents = keyValuePair.components(separatedBy: "=")
				let key = pairComponents.first?.removingPercentEncoding
				let value = pairComponents.last?.removingPercentEncoding
				queryStringDictionary[key ?? ""] = value
			}
			
			let selector = NSSelectorFromString(iosMethod)
			if(responds(to: selector) == true) {
				perform(selector)
			}
			
			if(debugMode == true) {
				print("requestURL: \(requestURL)")
				print("queryStringDictionary: \(queryStringDictionary)")
			}
			
		}
		
	}
	
	/*
	--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
	system
	--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
	*/

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	/*
	--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
	helloWorld
	--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
	*/
	
	let helloWorldSelector = #selector(helloWorld)
	@objc func helloWorld() {
		
		let synthesizer = NSSpeechSynthesizer()
		synthesizer.startSpeaking(queryStringDictionary["message"] ?? "")
		
		// process nativeCall successCallback function and send data to web UI
		let successResponse = "You have successfully called a native function from javascript, and you got schwifty!"
		
		var javaScript: String = ""
		if let successCallback = queryStringDictionary["successCallback"] {
			javaScript = "\(successCallback)('\(successResponse)');"
		}
		webView.evaluateJavaScript(javaScript, completionHandler: nil)
		
	}
	
}
