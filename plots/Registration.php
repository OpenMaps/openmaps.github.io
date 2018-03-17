<?php 
$page_title = 'Registration | Securing Land for prosperity';
include ('./includes/header.html');
?> 
<html lang="en">
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
			<!--email:urithi@gmail.com,joshua/mwaura@gmail.com,-->
			<section class="main">
				<form class="form-2" method="post" action="registration.php">
					<h1><span class="sign-up">sign up</span></h1>
					<p class="float">
						<label for="email"><i class="icon-user"></i>Email</label>
						<input type="text" name="email" placeholder="Email" readonly onfocus="this.removeAttribute('readonly')">
					</p>
					<p class="float">
						<label for="pass"><i class="icon-lock" ></i>Password</label>
						<input type="password" name="pass" placeholder="Password" readonly onfocus="this.removeAttribute('readonly')">
					</p>
					<p class="clearfix"> 
					<input type="submit" value="register" name="register">
					</p>
				</form>​​
				<center><b>Already registered ?</b> <br></b><a href="Login.php">Login here</a></center>
			</section>
        </div>
</body>  
  
</html>  
  
<?php  
include("./includes/db_connection.php");  	
if(isset($_POST['register'])){
	//here getting result from the post array after submitting the form.
	$user_pass=pg_escape_string($_POST['pass']);  
	$user_email=pg_escape_string($_POST['email']);  
  
	if($user_pass==''){   
		exit();  
	}  
  
	if($user_email==''){    
		exit();  
	}  
	
	$check_email_query = "SELECT email from public.users WHERE email='$user_email'";  
	$run_query=pg_query($con,$check_email_query);  
  
	if(pg_num_rows($run_query) > 0){  
		echo "<script>alert('Email $user_email is already exist in our database, Please try another one!')</script>";  
		exit();  
	}  
	//database.	
	$new_user="INSERT INTO public.users (email, pass, registration_date) VALUES (
			'$user_email', crypt('$user_pass', gen_salt('md5')), NOW())";  
	if(pg_query($con,$new_user)){  
		echo"<script>window.open('map.php','_self')</script>";  
	}   
}   
?>  
