<?php 
/** 
 * Created by OpenMaps.
 * Date: 02/02/2016  
 */
$page_title = 'Admin Login | Securing Land for prosperity';
include ('./includes/header.html');
?>
<html>    
<body>  
<div class="w3-container">
	<div class="om-top">
		<a href="./index.html">
			<strong>Geolocation Service</strong>
		</a>
	</div>
			
        <header class="w3-container w3-light-grey w3-round-large">
            <div class="w3-container w3-grey">
		<div class="w3-center"><p><h1>Cooperative Society Ltd</h1>
		<h2>Geolocation of realty</h2></div>
            </div>
        </header>
	<section class="main">
		<form class="form-4" method="post" action="Admin_Login.php">
			<h1><span class="log-in">Log in</span></h1>
				<p class="float">
					<label for="admin_name"><i class="icon-user"></i>Admin Name</label>
					<input type="text" name="admin_name" placeholder="Admin name">
				</p>
				<p class="float">
					<label for="admin_pass"><i class="icon-lock"></i>Password</label>
					<input type="password" name="admin_pass" placeholder="Password" readonly onfocus="this.removeAttribute('readonly')">
				</p>
				<div style="height:80px; text-align:center;">
				  <br/>
				  <div class="select_join" style="margin-left:15px">
					<select id="did" name="did">
					  <option>-- Select Page to Access --</option>
					  <option value="1">Projects</option>
					  <option value="2">Users Page</option>
					</select>
				  </div>
				</div>
				<p class="clearfix"> 
				<input type="submit" name="submit" value="Log in">
				</p>
		</form>​​
	</section>  
</div>
</body>  
</html>  
  
<?php     
include ('./includes/db_connection.php');  
  
if(isset($_POST['submit'])){ 
	 
    $admin_name=pg_escape_string($_POST['admin_name']);  
    $admin_pass=pg_escape_string($_POST['admin_pass']);  
	$page = $_POST['did'];
	switch($page){
		case 1:
		$admin_query="select admin_name, admin_pass from public.admin where (admin_name='$admin_name' AND admin_pass= crypt('$admin_pass',admin_pass))";  
		$run_query=pg_query($con,$admin_query);
		if(pg_num_rows($run_query)==1){  
			echo "<script>window.open('projects.php','_self')</script>";  
		}  
		else {
			echo"<script>alert('Incorrect Details, try again')</script>";
		}
		break;
		
		case 2:
		$admin_query="select admin_name, admin_pass from public.admin where (admin_name='$admin_name' AND admin_pass= crypt('$admin_pass',admin_pass))";  
		$run_query=pg_query($con,$admin_query);
		if(pg_num_rows($run_query)==1){  
			echo "<script>window.open('View_users.php','_self')</script>";  
		}  
		else {
			echo"<script>alert('Incorrect Details, try again')</script>";
		}
		break;
	}
}
?> 
