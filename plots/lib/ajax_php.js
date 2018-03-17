// ajax.js

/*	This page defines a function for creating an Ajax request object.
 *	This page should be included by other pages that 
 *	need to perform an XMLHttpRequest.
 */
 
/*	Function for creating the XMLHttpRequest object.
 *	Function takes no arguments.
 *	Function returns a browser-specific XMLHttpRequest object
 *	or returns the Boolean value false.
 */
function getXMLHttpRequestObject() {

	// Initialize the object:
	var ajax = false;

	// Choose object type based upon what's supported:
	if (window.XMLHttpRequest) {
	
		// IE 7, Mozilla, Safari, Firefox, Opera, most browsers:
		ajax = new XMLHttpRequest();
		
	} else if (window.ActiveXObject) { // Older IE browsers
	
		// Create type Msxml2.XMLHTTP, if possible:
		try {
			ajax = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) { // Create the older type instead:
			try {
				ajax = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) { }
		}
		
	} // End of main IF-ELSE IF.
	
	// Return the value:
	return ajax;

} // End of getXMLHttpRequestObject() function.
