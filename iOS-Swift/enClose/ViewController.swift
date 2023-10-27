//
//  ViewController.swift
//  enClose
//
//  Created by Work on 9/11/18.
//

import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {

	var queryStringDictionary = [String: String]()
	var iosParameters = ""
	let debugMode = true
    let synthesizer = AVSpeechSynthesizer()
	var webView: WKWebView!

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

		guard let request = message.body as? String else { return }
		
		if(request.hasPrefix("ios:") == true) {
			
			// call the native method if exists
			var range: NSRange
			range = NSRange(location: 0, length: Int((request as NSString).range(of: "?").location))
			var iosMethod = (request as NSString).substring(with: range)
			iosMethod = iosMethod.replacingOccurrences(of: "ios:", with: "")
			
			range = NSRange(location: Int((request as NSString).range(of: "?").location) + 1, length: (request.count - Int((request as NSString).range(of: "?").location)) - 1)
			iosParameters = (request as NSString).substring(with: range)
			
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
				print("request: \(request)")
				print("queryStringDictionary: \(queryStringDictionary)")
			}
			
		}
		
	}

	/*
	--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
	system
	--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
	*/

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	/*
	--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
	helloWorld
	--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
	*/
	
	let helloWorldSelector = #selector(helloWorld)
	@objc func helloWorld() {
	
		// play system alet sound
        let s = Speaker()
        s.speak(msg: queryStringDictionary["message"] ?? "")
		
		// process nativeCall successCallback function and send data to web UI
		let successResponse = "You have successfully called a native function from javascript, and you got schwifty!"
		
		var javaScript: String = ""
		if let successCallback = queryStringDictionary["successCallback"] {
			javaScript = "\(successCallback)('\(successResponse)');"
		}
		webView.evaluateJavaScript(javaScript, completionHandler: nil)
		
	}
	
}
