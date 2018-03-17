<?php # pg_connect.php
/*
 *$username = 'openmaps_u';
 $password = '19@root#89';
 $database = 'openmaps_db';
 $server = '137.74.106.9';
 * */
# Connect to postgreSQL database
$conn = new PDO('pgsql:host=localhost;dbname=wambui','postgres','root');	

?>
