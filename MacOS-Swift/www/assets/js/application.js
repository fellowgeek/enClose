// Global variables
var debugMode = true;

// Startup
document.addEventListener('DOMContentLoaded', function () {

	FastClick.attach(document.body);

	console.log('Ready.');

	let myButton = document.querySelector('.buttonTestenClose');
	myButton.addEventListener('click', function() {
		enClose({
			nativeCall: 'helloWorld',
			data: {
		  		message: 'Oh, yeah! You gotta get schwifty. You gotta get schwifty in here.'
			},
			successCallback: 'successCallbackFunction'
		});
    });

});

// Call back for success
function successCallbackFunction(response) {

	console.log(response);
	let myResponse = document.querySelector('.response');
	myResponse.innerHTML = response;

}
