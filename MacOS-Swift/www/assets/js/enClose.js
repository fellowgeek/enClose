// enClose - This function is the entry point for invoking native methods from the WebView side, with support for success and error callbacks.
function enClose(options = {
    nativeCall: '',          // The name of the native method to be called.
    data: {},                // Data to be sent to the native method.
    successCallback: null,   // A JavaScript callback function to handle success.
    errorCallback: null      // A JavaScript callback function to handle errors.
}) {
    // Construct query parameters for the native method call.
    var parameters = '';
    for (var key in options.data) {
        if (parameters != '') {
            parameters += "&";
        }
        parameters += key + '=' + encodeURIComponent(options.data[key]);
    }

    // Construct the URI to invoke the native method with callbacks.
    var enCloseURI = 'ios:' + options.nativeCall + ':?' + parameters;
    if (options.successCallback) {
        enCloseURI += '&successCallback=' + options.successCallback;
    }
    if (options.errorCallback) {
        enCloseURI += '&errorCallback=' + options.errorCallback;
    }

    // Check if debug mode is enabled, and log relevant information.
    if (typeof __DEBUG_MODE__ !== 'undefined' && __DEBUG_MODE__ == true) {
        console.log('%c> enClose options:', 'font-weight: bold; color: #000;');
        console.log(`%c${JSON.stringify(options, undefined, 2)}`, 'color: #222; background-color: #ffd; font-family: menlo, consolas, monospace');
    }

    try {
        // Invoke the native method using the WebView's messageHandlers.
        webkit.messageHandlers.enClose.postMessage(enCloseURI);
    } catch (err) {
        // Handle the case when the native code cannot be reached.
        if (typeof __DEBUG_MODE__ !== 'undefined' && __DEBUG_MODE__ == true) {
            console.error('Error: Unable to communicate with native code.');
        }
    }
}

// A debug-only function that logs messages to the JavaScript and Xcode consoles.
function enCloseLog(...message) {
    if (typeof __DEBUG_MODE__ !== 'undefined' && __DEBUG_MODE__ === true) {

        let callSite = { link: '', file: 'unknown', function: '(anonymous)', line: '0' };

        try {
            // Create an error object to capture the stack trace
            const err = new Error();

            // err.stack is a string containing the stack trace.
            if (err.stack) {
                const stackLines = err.stack.split('\n');
                const callerLine = stackLines[1] || ''; // Use index 1, provide fallback

                // Use regex to extract file, function and line number
                const match = callerLine.match(/^(?:(\w+)?@)?(?:https?:\/\/[^\/]+|file:\/\/\/)?([^:]+)(?::(\d+))?/);
                if (match && match[2] && match[3]) {
                    callSite.link = match[0].trim();
                    callSite.file = match[2].trim();
                    callSite.function = match[1] || '(anonymous)';
                    callSite.line = match[3];
                }
            }
        } catch (e) {
            // Handle any error during stack trace parsing
            console.error("Error getting call site:", e);
        }

        // Add file and line info to the log message
        console.log(callSite.link);
        console.log(...message);

        enClose({
            nativeCall: 'enCloseLog',
            data: {
                message: message.join(', '),
                file: callSite.file,
                function: callSite.function,
                line: callSite.line
            }
        });
    }
}

// Dispatch a custom enClose event
function enCloseEvent(data) {
    const event = new CustomEvent(
        "enclose:event",
        {
            detail: data,
            bubbles: true
        }
    );
    document.dispatchEvent(event);
}
