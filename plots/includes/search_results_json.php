<?php 
# search_results_json.php
$var = $_GET['f_r'];
// Validate the received:
if (!empty($var)) {
  // Get the parcels from the database...
  // Include the database connection script:
  require_once('db_connection.php');
  
  // Query the database:
	$q = "SELECT land_owner,f_r,area_ha FROM parcels WHERE f_r LIKE '".$var. "'";
	$r = pg_query($con, $q);
	$data = array();
  
    // Retrieve the results:
    while ($row = pg_fetch_assoc($r)) {
    	$data[] =$row;      
    } // End of WHILE loop.
    
    echo json_encode($data); 
    // Print the JSON data:    
  } 
  
  // Close the database connection.
 pg_close($con);
  
} // End of $_GET['lr_no'] IF.

?>
