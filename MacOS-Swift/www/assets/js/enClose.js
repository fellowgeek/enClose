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
    var enCloseURI = 'ios:' + options.nativeCall + '?' + parameters;
    if (options.successCallback) {
        enCloseURI += '&successCallback=' + options.successCallback;
    }
    if (options.errorCallback) {
        enCloseURI += '&errorCallback=' + options.errorCallback;
    }

    // Check if debug mode is enabled, and log relevant information.
    if (typeof debugMode !== 'undefined' && debugMode == true) {
        console.log('%c> enClose options:', 'font-weight: bold; color: #000;');
        console.log(`%c${JSON.stringify(options, undefined, 2)}`, 'color: #222; background-color: #ffd; font-family: menlo, consolas, monospace');
    }

    try {
        // Invoke the native method using the WebView's messageHandlers.
        webkit.messageHandlers.enClose.postMessage(enCloseURI);
    } catch (err) {
        // Handle the case when the native code cannot be reached.
        if (debugMode == true)
            console.error('Error: Unable to communicate with native code.');
    }
}
