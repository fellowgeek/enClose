/*
 ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
 UTILITY FUNCTIONS
 ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
*/

$(function() {
	FastClick.attach(document.body);
});

var $debugMode = true;

// call a native objective-c method
function nativeCall($url, $delay) {
    if (typeof($delay)==='undefined') $delay = 0;
    window.setTimeout(function(){
        if($debugMode == true) { console.log($url); }
        window.location.hash = $url;
    }, $delay);
}
/*
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
STARTUP
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
*/
$(document).ready(function() {

	console.log('Ready.');
                  
    $('#test').click(function() {
        console.log('Clicked.');
        nativeCall('ios:helloWorld?paramText=test&paramNumber=666&paramJSON={"key1":"value1","key2":"value2"}');
    });

});
