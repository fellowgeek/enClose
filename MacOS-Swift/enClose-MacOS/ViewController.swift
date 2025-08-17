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
        webView.underPageBackgroundColor = .black
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
            if (ViewController.debugMode == true) {
                webView.isInspectable = true
            }
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

    }

    // Function to disable user text selection via JavaScript
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        // Gather information about the system
        let processInfo = ProcessInfo.processInfo

        let javaScriptConstants = """
            const __DEBUG_MODE__ = \(ViewController.debugMode);
            const __DEVICE_NAME__ = 'Mac';
            const __DEVICE_MODEL__ = '';
            const __DEVICE_SYSTEM_NAME__ = '\(processInfo.hostName)';
            const __DEVICE_SYSTEM_VERSION__ = '\(processInfo.operatingSystemVersionString)';
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

            // Check if debug mode is enabled print information
            if(ViewController.debugMode == true && iosMethod != "enCloseLog:") {
                // Print the original request and the queryStringDictionary
                Logger.info("Attempting to call native method: \(iosMethod)")
                print(String(data: try! JSONSerialization.data(withJSONObject: queryStringDictionary, options: .prettyPrinted), encoding: .utf8)!)
            }

            // Convert the method name into a selector
            let selector = NSSelectorFromString(iosMethod)
            // Check if the current object responds to the selector
            if(responds(to: selector) == true) {
                // If it does, perform the method
                perform(selector, with: queryStringDictionary)
            } else {
                Logger.info("Unable to find @objc method for selector: \(selector)")
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
        if (ViewController.debugMode == true) {
            Logger.info("Evaluating Javascript (main):\n>_ \(javaScript)")
        }
        webView.evaluateJavaScript(javaScript, completionHandler: nil)
    }

    // enClose debug function to be called from javascript to display debug logs in Xcode
    @objc func enCloseLog(_ params: [String: String]) {
        
        if let message = params["message"] {
            Logger.debug(message,
                         file: params["file"] ?? "",
                         function: params["function"] ?? "",
                         line: Int(params["line"] ?? "0") ?? 0
            )
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: JavaScript Native Interface
    /*
    This section bridges JavaScript calls to native Swift implementations.
    Add your @objc exposed functions below this comment block to maintain code organization.
    Keep interface methods simple and delegate complex logic to dedicated classes.
    */

    // A custom "Hello, World!" function which is called from Javascript, it speaks a message
    @objc func helloWorld(_ params: [String: String]) {
        var javaScript: String = ""

        // process nativeCall successCallback function and send data to web UI
        let successResponse = "You have successfully called a native function from javascript, congratulations!"
        if let successCallback = params["successCallback"] {
            javaScript = "\(successCallback)('\(successResponse)');"
        }
        evaluateJavascript(javaScript: javaScript)
    }

}
