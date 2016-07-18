#WHAT IS IT?
enClose is a HTML5 wrapper for iOS and OSX. enClose comes with all the tools you know and love like jQuery, Bootstrap, Font Awesome, and FastClick but you don't have to use any of them if you don't want to.

FastClick makes your HTML5 apps work and feel as fast as native apps in terms of responsiveness on iOS.

enClose lets you call native functions from your JavaScript app and call JavasSrcipt functions from your native part of the app.

#WHY SHOULD I CARE?
PhoneGap is limited, over complicated, and stupid. It only gives you a set of function through the API, why not take advantage of everything that iOS or OSX platform can offer, duh!.

enClose is super simple and flexible, you have the freedom to everything the way you want, the whole thing is 40 lines of code, really!

#HOW DOES IT WORK?
Glad you asked, when a native function is called through a special URL from the JavaScript, the UIWebView on the native side catches this URL and calls the correct method on the native side. to call a JavaScript function from native we simply use the UIWebView method "stringByEvaluatingJavaScriptFromString".

This is how a native function is called from JavaScript, in this example:

<pre>
jQuery.enClose([settings])

settings: (PlainObject)

	nativeCall: (String)			(name of the native (Objective-C) method)
	data: (PlainObject)				(data to be sent to the native (Objective-C) method)
	successCallback: (String)		(name of the JavaScript callback function to be called on success)
	errorCallback: (String)			(name of the JavaScript callback function to be called on error)

$.enClose({
	nativeCall: 'helloWorld',
	data: {message: 'Hello, from the other side.', speed: 0.5},
	successCallback: 'successCallbackFunction'
});
</pre>

Or if you don't want to use jQuery or JavaScript you can call native methods via URL, see example below:

<pre>

	<a href="ios:nativeCall?parameters">link label</a>

	nativeCall: (String)			(name of the native (Objective-C) method)
	parameters: (String)			(url parameters to be sent to the native (Objective-C) method)

<a href="ios:helloWorld?message=Hello, from the other side.&speed=0.5&successCallback=successCallbackFunction">Hello World</a>	

</pre>

That is all. Below you can see pretty much the whole source code in less than 40 lines of code.

<pre>
if ([requestURL hasPrefix:@"ios:"]) {

    NSLog(@"%@", requestURL);

    // call the native method if exists
    NSRange range;
    range = NSMakeRange(0, [requestURL rangeOfString:@"?"].location);
    NSString *iosMethod = [requestURL substringWithRange:range];
    iosMethod = [iosMethod stringByReplacingOccurrencesOfString:@"ios:" withString: @""];

    range = NSMakeRange(
    	([requestURL rangeOfString:@"?"].location + 1),
    	([requestURL length] - [requestURL rangeOfString:@"?"].location) - 1);
    iosParameters = [requestURL substringWithRange:range];

    [queryStringDictionary removeAllObjects];
    NSArray *urlComponents = [iosParameters componentsSeparatedByString:@"&"];
    for(NSString *keyValuePair in urlComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        [queryStringDictionary setValue:value forKey:key];
    }

    SEL selector = NSSelectorFromString(iosMethod);
    if([self respondsToSelector: selector] == YES) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector];
        #pragma clang diagnostic pop
    }
    // cancel the location change
    return NO;
}
</pre>

#WHAT ABOUT ANDROID?
If you are developing on Android platform, DON'T.


#GIVE ME THE CODE
Go ahead and click on the link below and the code is yours. OSX version coming soon. in the meantime you can turn this into the OSX version yourself.

https://github.com/fellowgeek/enClose/archive/1.4-iOS.zip

#SUPPORT ME?

<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="DUDTFAE4EYZUU">
<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>

#LICENSE
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
