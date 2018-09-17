/*
 ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
 GLOBAL VARIABLES
 ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
*/
var debugMode = true;

/*
 ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
 ATTACH FAST CLICK
 ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
*/

$(function() {
	FastClick.attach(document.body);
});


/*
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
STARTUP
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
*/
$(document).ready(function() {

	console.log('Ready.');

    $('.buttonTestenClose').click(function() {

		$.enClose({
			nativeCall: 'helloWorld',
			data: {message: 'Hello, from the other side.', speed: 0.5},
			successCallback: 'successCallbackFunction'
		});

    });

});

function successCallbackFunction(response) {

	console.log(response);
	$('.response').html(response);

}