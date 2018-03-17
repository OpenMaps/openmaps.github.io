<?php 
$page_title = 'Login | Securing Land for prosperity';
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
		
		
		<section class="main">
			<form class="form-2" method="post" action="Login.php">
			<h1><span class="log-in">Log in</span></h1>
				<p class="float">
					<label for="email"><i class="icon-user"></i>Email</label>
					<input type="text" name="email" placeholder="email">
				</p>
				<p class="float">
					<label for="passwd"><i class="icon-lock"></i>Password</label>
					<input type="password" name="passwd" placeholder="Password" readonly onfocus="this.removeAttribute('readonly')" class="showpassword">
				</p>
				<p class="clearfix"> 
				<input type="submit" name="login" value="Log in">
				</p>
			</form>​​
		</section>
</div>  
</body>  
</html>  
<?php  
  
include("./includes/db_connection.php");   
if(isset($_POST['login']))  
{  
	$user_email=pg_escape_string($_POST['email']);  
	$user_pass=pg_escape_string($_POST['passwd']);  
  
	$check_user="SELECT email,pass FROM public.users WHERE (
	email= lower('$user_email') AND 
	pass= crypt('$user_pass', pass))";  
  
	$run=pg_query($con,$check_user);  
  
	if(pg_num_rows($run)== 1)  
	{  
		echo "<script>window.open('map.php','_self')</script>";  
  
		$_SESSION['email']=$user_email;//here session is used and value of $user_email store in $_SESSION.  
  
	}  
	else  
	{  
	  echo "<script>alert('Email or password is incorrect!')</script>";  
	}  
}  
?>  
