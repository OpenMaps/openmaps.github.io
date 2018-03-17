<?php 
/** 
     * Created by OpenMaps.
     * Date: 02/02/2016      
$con=mysqli_connect("localhost","root","");  
mysqli_select_db($con,"user");  */
/*
 *$username = 'openmaps_u';
 $password = '19@root#89';
 $database = 'openmaps_db';
 $server = '137.74.106.9';
 * */
 # pgsql_connect.php
$con = pg_connect("dbname=postgres user=postgres password=root host=localhost port=5432");
# OR die ('Could not connect to PgSQL:' . pg_error())
#include('./includes/footer.html');

function escape_data ($data) {
	if (ini_get('magic_quotes_gpc')) {
		$data = stripslashes($data);
	}
	if (function_exists('pg_escape_string')) {
		global $con;
		$data = pg_escape_string($con, trim($data));
	} else {
		$data = pg_escape_string($con, trim($data));
	}
	return $data;
}
?>
