<?php 
$page_title = 'Users | Securing Land for prosperity';
include ('./includes/header.html');
?> 
<html>  
<head lang="en">   
    <link type="text/css" rel="stylesheet" href="./css/bootstrap.min.css"> 
</head>  
<style> 
</style>  
  
<body>  
<div class="container">
	<!--top bar -->
	<div class="openmaps-top">
		<a href="./View_users.php">
			<strong>All the Users</strong>
		</a>
		<span class="right">
			<a href="./Logout.php">
				<strong>Admin Logout</strong>
			</a>
		</span>
	</div>
</div>
<div class="table-scrol">  
<div class="table-responsive"><!--this is used for responsive display in mobile and other devices-->  
    <table class="table table-bordered table-hover table-striped" style="table-layout: fixed" align="center">  
        <thead>  
        <tr>  
            <th>User Id</th>   
            <th>User E-mail</th> 
			<th>Registration Date</th> 
            <th>Delete User</th>  
        </tr>  
        </thead>  
  
        <?php  
        include("./includes/db_connection.php");
		//require_once ('./includes/db_connection.php');		
        $view_users_query="select * from public.users";//select query for viewing users.  
        $run=pg_query($con,$view_users_query);//here run the sql query.  
  
        while($row=pg_fetch_array($run))//while look to fetch the result and store in a array $row.  
        {  
            $user_id=$row[0];   
            $user_email=$row[1];   
			$registration_date=$row[7];
        ?>  
  
        <tr>  
		<!--table -->  
            <td><?php echo $user_id;  ?></td>  
            <td><?php echo $user_email;  ?></td> 
            <td><?php echo $registration_date;  ?></td> 
            <td><a href="Delete.php?del=<?php echo $user_id ?>"><button class="btn btn-danger">Delete</button></a></td> <!--btn btn-danger is a bootstrap button to show danger-->  
        </tr>  
  
        <?php } ?>  

    </table>  
        </div>  
</div>    
</body>   
</html>
