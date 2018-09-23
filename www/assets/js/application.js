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
			data: {
				  message: 'Oh, yeah! You gotta get schwifty. You gotta get schwifty in here.'
			},
			successCallback: 'successCallbackFunction'
		});

    });

});

function successCallbackFunction(response) {

	console.log(response);
	$('.response').html(response);

}
