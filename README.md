# What is enClose?
![Logo](iOS-Swift/www/assets/images/enCloseLogo.png)

enClose is an HTML5 wrapper tailored for iOS and OSX, enriching your development experience. With enClose, you can harness familiar tools to build native Swift applications.

[FastClick](https://github.com/ftlabs/fastclick) empowers your HTML5 applications to match the responsiveness of native apps on iOS, offering a seamless user experience.

Moreover, enClose facilitates the seamless interaction between native functions and JavaScript within your application. It allows you to invoke native functions from your JavaScript app and JavaScript functions from the native components of your application.

# Why is it Worth Your Attention?
Unlike PhoneGap, which can be limiting and overly intricate, enClose offers a refreshing alternative. It doesn't confine you to a predefined set of functions via an API; instead, it enables you to tap into the full potential of the iOS and OSX platforms.

enClose is designed to be remarkably straightforward and flexible. You're in control, with the freedom to structure your code as you see fit. In fact, the entire framework consists of just a few blocks of code – that's simplicity at its finest.

# How Does it Function?
You might be intrigued by the underlying mechanics of enClose. Here's how it operates: When a native function is triggered from JavaScript, enClose leverages WebKit messageHandlers to dispatch a message to WKScriptMessageHandler on the native side, facilitating subsequent processing. The code then searches for the existence of the native method. If the method is found, it is executed, and subsequently, the JavaScript success and error callbacks are invoked.

Here's an example of calling a native function from JavaScript:

<pre>
enClose(options)

options: (PlainObject)

	nativeCall: (String)			(name of the native (Swift) method)
	data: (PlainObject)                     (data to be sent to the native (Swift) method)
	successCallback: (String)		(name of the JavaScript callback function to be called on success)
	errorCallback: (String)			(name of the JavaScript callback function to be called on error)

enClose({
    nativeCall: 'helloWorld',
    data: {
        message: 'Hello, from the other side.'
    },
    successCallback: 'successCallbackFunction'
});
</pre>

Or if you don't want to use JavaScript you can call native methods via URL, see example below:

<pre>
// Invoke the native method using the WebView's messageHandlers.
webkit.messageHandlers.enClose.postMessage(enCloseURI);

enCloseURI: 'ios:nativeCall?parameters'

nativeCall: (String)            (name of the native (Swift) method)
parameters: (String)		(url parameters to be sent to the native (Swift) method)

</pre>

That is all. Below you can see pretty much the whole source code at the heart of enClose in a block of code.

```
// Check if the request starts with "ios:"
if request.hasPrefix("ios:") {  
    // Extract and process the method name and parameters from the request
    var range: NSRange  // Declare a variable to hold a range

    // Find the range from the start of the string to the first "?" character
    range = NSRange(location: 0, length: Int((request as NSString).range(of: "?").location))

    // Extract the method name from the request and remove "ios:"
    var iosMethod = (request as NSString).substring(with: range)
    iosMethod = iosMethod.replacingOccurrences(of: "ios:", with: "")

    // Find the range from the character after the first "?" to the end of the string
    range = NSRange(location: Int((request as NSString).range(of: "?").location) + 1, length: (request.count - Int((request as NSString).range(of: "?").location)) - 1)
    let iosParameters = (request as NSString).substring(with: range)

    // Initialize an empty dictionary to store key-value pairs
    var queryStringDictionary = [String: String]()

    // Split the parameters into key-value pairs
    let urlComponents = iosParameters.components(separatedBy: "&")
    for keyValuePair in urlComponents {
        let pairComponents = keyValuePair.components(separatedBy: "=")
        let key = pairComponents.first?.removingPercentEncoding
        let value = pairComponents.last?.removingPercentEncoding

        // Add key-value pairs to the dictionary
        queryStringDictionary[key ?? ""] = value
    }

    // Convert the method name into a selector
    let selector = NSSelectorFromString(iosMethod)

    // Check if the current object responds to the selector
    if responds(to: selector) {
        // If it does, perform the method
        perform(selector)
    }

    // Check if debug mode is enabled
    if debugMode {
        // Print the original request and the queryStringDictionary
        print("request: \(request)")
        print("queryStringDictionary: \(queryStringDictionary)")
    }
}
```

# What about Android?
If you are developing on Android platform, download enClose from [here](https://www.youtube.com/watch?v=dQw4w9WgXcQ): 


# Getting Started
To get started, just clone the repository and open the enClose project in Xcode. Currently, enClose offers two distinct versions for both iOS and MacOS.

# Support
If you'd like to support my work, you can visit my Cash App at https://cash.me/$fellowgeek. Your support is greatly appreciated!

