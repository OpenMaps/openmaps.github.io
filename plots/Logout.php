<?php 
/** 
 * Created by OpenMaps.
 * Date: 02/02/2016  
 */
$page_title = 'Logout | Securing Land for prosperity';

session_destroy();  
header("Location: index.html");//use for the redirection to some page  
?>  