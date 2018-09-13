//
//  ViewController.swift
//  enClose
//
//  Created by Work on 9/11/18.
//

import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {

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
		let synthesizer = AVSpeechSynthesizer()
		let utterance = AVSpeechUtterance(string: queryStringDictionary["message"] ?? "")
		
		if queryStringDictionary.keys.contains("speed") == true {
			utterance.rate = (queryStringDictionary["speed"]! as NSString).floatValue
		}
		
		synthesizer.speak(utterance)
		
		// process nativeCall successCallback function and send data to web UI
		let successResponse = "You have successfully called this native function."
		
		var javaScript: String = ""
		if let successCallback = queryStringDictionary["successCallback"] {
			javaScript = "\(successCallback)('\(successResponse)');"
		}
		webView.evaluateJavaScript(javaScript, completionHandler: nil)
		
	}
	
}
