/*
 ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
 ENCLOSE
 ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
*/
(function ($) {
	$.extend({
		enClose: function(options) {
			var options = $.extend({
				nativeCall: '',
				data: {},
				successCallback: '',
				errorCallback: ''
			}, options);

			var parameters = '';
			for (var key in options.data) {
				if (parameters != '') {
					parameters += "&";
				}
				parameters += key + '=' + encodeURIComponent(options.data[key]);
			}

			var enCloseURI = 'ios:' + options.nativeCall + '?' + parameters + '&successCallback=' + options.successCallback + '&errorCallback=' + options.errorCallback;

			if(typeof debugMode !== 'undefined' && debugMode == true) {
				console.log(options);
				console.log('enClose URI: ', enCloseURI);
			}

			 try {
			 	webkit.messageHandlers.enClose.postMessage(enCloseURI);
			 } catch(err) {
			 	console.error('Can not reach native code.');
			 }
		}
	})
}(jQuery));
