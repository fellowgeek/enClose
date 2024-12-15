//
//  ExternalDisplayViewController.swift
//  enClose
//
//  Created by Erfan Reed on 12/13/24.
//

import UIKit
@preconcurrency import WebKit

class ExternalDisplayViewController: UIViewController, WKNavigationDelegate {

    static var sharedWebView: WKWebView?
    
    // Declare the first webpage to be loaded
    var index: String = "index" 
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
               
        webView = WKWebView(frame: .zero)
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
        
        ExternalDisplayViewController.sharedWebView = webView
        
        if let url = Bundle.main.url(forResource: self.index, withExtension: "html", subdirectory: "www") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    // Send a notification when external display web view finished loading the page
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        // Post a notification when external display web view finished loading
        NotificationCenter.default.post(name: .externalDisplayWebViewFinishedLoading, object: nil)
    }
    
}

extension Notification.Name {
    static let externalDisplayWebViewFinishedLoading = Notification.Name("externalDisplayWebViewFinishedLoading")
}
