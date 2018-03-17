//ajax.js
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

//search_json.js 
// Have a function run after the page loads:
window.onload = init;

// Function that adds the Ajax layer:
function init () {

  // Get an XMLHttpRequest object:
  var ajax = getXMLHttpRequestObject();
  
  // Attach the function call to the form submission, if supported:
  if (ajax) {
  
    // Check for DOM support:
    if (document.getElementById('rcorners2')) {
    
      // Add an onsubmit event handler to the form:
      document.getElementById('search_form').onclick = function() {
      
        // Call the PHP script.
        // Use the GET method.
        // Pass the lr_no
        
        // Get the lr_no:
        var lr_no = document.getElementById('lr_no').value;
        
        // Open the connection:
        ajax.open('get', './search_results_json.php?lr_no=' + encodeURIComponent(lr_no));
      
        // Function that handles the response:
        ajax.onreadystatechange = function() {
          // Pass it this request object:
          handleResponse(ajax);
        }
        
        // Send the request:
        ajax.send(null);
      
        return false; // So form isn't submitted.

      } // End of anonymous function.
      
    } // End of DOM check.
    
  } // End of ajax IF.

} // End of init() function.

// Function that handles the response from the PHP script:
function handleResponse(ajax) {

  // Check that the transaction is complete:
  if (ajax.readyState == 4) {
  
    // Check for a valid HTTP status code:
    if ((ajax.status == 200) || (ajax.status == 304) ) {

      // Clear the current results content:
      var results = document.getElementById('rcorners2');
      
      // Make the results box visible:
      results.style.display = 'block';
        
      while (results.hasChildNodes()) {
        results.removeChild(results.lastChild);
      }
      
      // Get the data from the response:
      var data = eval('(' + ajax.responseText + ')');

      // Check that some employees were returned:
      if (data.length > 0) {
      
        // Declare some necessary variables:
        var parcels, span, owner_node, fr_node, f_r_label, br, strong, a, Area;

        // Loop through each employee:
        for (var i = 0; i < data.length; i++) {
        
          parcels = document.createElement('p');
          
          span = document.createElement('span');
          span.setAttribute('class', 'Owner');
          owner_node = document.createTextNode(data[i].land_owner);
          span.appendChild(owner_node);
          parcels.appendChild(span);
          
          br = document.createElement('br');
          parcels.appendChild(br);
          
          strong = document.createElement('strong');
          f_r_label = document.createTextNode('FR No.');
          strong.appendChild(f_r_label);
          
          parcels.appendChild(strong);
          fr_node = document.createTextNode(': ' + data[i].f_r);
          parcels.appendChild(fr_node);
          
          br = document.createElement('br');
          parcels.appendChild(br);
          
          a = document.createElement('a');
          a.setAttribute('href', 'mailto:' + data[i].area_ha);
          Area = document.createTextNode(data[i].area_ha);
          a.appendChild(Area);
          parcels.appendChild(a);
          
          results.appendChild(parcels);
          
        } // End of FOR loop.
        
      } else { // No employees, print a message.
      
      	// Create a new paragraph:
        var node1 = document.createElement('p');
        
        // Add the class:
        node1.setAttribute('class', 'error');
        
        // Create a text node:
        var node2 = document.createTextNode('No data available.');
        
        // Add the text node to the paragraph:
        node1.appendChild(node2);
        
        // Add the paragraph to the results:
        results.appendChild(node1);
        
      }

    } else { // Bad status code, submit the form.
    
      document.getElementById('search_form').submit();
      
    }
    
  } // End of readyState IF.
  
} // End of handleResponse() function.


