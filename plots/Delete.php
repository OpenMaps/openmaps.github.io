<?php  
/** 
     * Created by OpenMaps.
     * Date: 02/02/2016  
     */   
include("./includes/db_connection.php");  
$delete_id=$_GET['del'];  
$delete_query="delete  from public.users WHERE user_id='$delete_id'";//delete query  
$run=pg_query($con,$delete_query);  
if($run)  
{  
//javascript function to open in the same window   
    echo "<script>window.open('View_users.php?deleted=user has been deleted','_self')</script>";  
}  
  
?> 
