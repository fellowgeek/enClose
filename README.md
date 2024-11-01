# What is enClose?
![Logo](iOS-Swift/www/assets/images/enCloseLogo.png)

enClose is an HTML5 wrapper for iOS and macOS that streamlines your development. It lets you leverage familiar web tools to build native Swift applications while enabling smooth communication between native code and JavaScript. With enClose, you can call native functions from JavaScript and vice versa.

# Why Choose enClose?
Unlike other frameworks like PhoneGap, which can feel restrictive, enClose offers flexibility without confining you to predefined functions. It provides direct access to the full capabilities of iOS and macOS, allowing you to structure code your way. The framework itself is compact, consisting of just a few lines of code for ease of use.

# How Does enClose Work?
enClose uses WebKit’s messageHandlers to send messages from JavaScript to WKScriptMessageHandler on the native side. Once received, enClose checks for the specified native method and executes it if available, then triggers the appropriate JavaScript callback based on success or failure.

Here’s an example of a JavaScript call to a native function:

### enClose(options)

|Option         |Type  |Description                                                     |
|---------------|------|----------------------------------------------------------------|
|nativeCall     |String|name of the native (Swift) method                               |
|data           |Object|data to be sent to the native (Swift) method                    |
|successCallback|String|name of the JavaScript callback function to be called on success|
|errorCallback  |String|name of the JavaScript callback function to be called on error  |

```javascript
enClose({
    nativeCall: 'helloWorld',
    data: {
        message: 'Hello, from the other side.'
    },
    successCallback: 'successCallbackFunction'
});
```

Alternatively, call native methods via messageHandlers:

```javascript
// Using WebView’s messageHandlers.
webkit.messageHandlers.enClose.postMessage('ios:nativeCall?parameters');
```

### enCloseURI: 'ios:nativeCall?parameters'
|Section   |Type  |Description                                           |
|----------|------|------------------------------------------------------|
|nativeCall|String|name of the native (Swift) method                     |
|parameters|String|url parameters to be sent to the native (Swift) method|

# Core Code of enClose
```swift
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
		// Print the original request and the queryStringDictionary
		print("request: \(request)")
		print("queryStringDictionary: \(queryStringDictionary)")
	}
}
```

# Android Version
Developing for Android? Download enClose for Android [here](https://www.youtube.com/watch?v=dQw4w9WgXcQ): 


# Getting Started
Clone the repository and open the enClose project in Xcode. enClose offers dedicated versions for iOS and macOS.

# Support
If you’d like to support my work, feel free to visit my Cash App at https://cash.me/$fellowgeek. Thank you for your support!

