// Event listener for custom "enclose:event" events
document.addEventListener('enclose:event', function (event) {
	console.log('enclose:event triggered.');
	console.log(event.detail);

	// This block handles the case when an external display is connected,
	// and the associated web view has finished loading.
	if (event.detail == 'externalDisplayWebViewFinishedLoading') {
		// Invoke the native function "updateExternalDisplayMessage"
		// to update the message displayed on the external monitor.
		enClose({
			nativeCall: 'updateExternalDisplayMessage',
			data: {
				// Provide the current timestamp as part of the message.
				message: 'External display connected at: ' + new Date().toLocaleString()
			}
		});
	}
});

// Execute the following code once the DOM has fully loaded.
document.addEventListener('DOMContentLoaded', function () {

	console.log('Ready.');

	// Add an event listener to the enClose logo for user interactions.
	const logo = document.querySelector('.logo');
	logo.addEventListener('click', function () {
		// Trigger the native "helloWorld" function through enClose.
		// Specify a callback function to handle the success response.
		enClose({
			nativeCall: 'helloWorld',
			successCallback: 'successCallbackFunction'
		});
	});

	// Dynamically add decorative floating circles to the blueprint background.
	addRandomElements();
});

// Callback function triggered by native code when the "helloWorld" call is successful.
function successCallbackFunction(response) {
	console.log(response);

	// Update the DOM element with class "response" to display the response data.
	let myResponse = document.querySelector('.response');
	myResponse.innerHTML = response;
}

// Function to add floating decorative circles to the blueprint background.
function addRandomElements() {
	const blueprint = document.querySelector('.blueprint');
	for (let i = 0; i < 15; i++) {
		const circle = document.createElement('div');
		circle.className = 'circle';
		const size = Math.random() * 200 + 50;
		circle.style.width = size + 'px';
		circle.style.height = size + 'px';
		circle.style.left = Math.random() * window.innerWidth + 'px';
		circle.style.top = Math.random() * window.innerHeight + 'px';
		circle.style.animationDelay = (Math.random() * 5) + 's';
		blueprint.appendChild(circle);
	}
}
