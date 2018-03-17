<?php 
$page_title = 'Welcome | Securing Land for prosperity';
include ('./includes/header.html'); 
if(!$_SESSION['email'])  
{  
	header("Location: login.php"); 
}  
?>        
<html>  

    <body>
        <div class="container">
		
			<!-- openmaps top bar -->
            <div class="openmaps-top">
                <a href="">
                    <strong>&laquo;<?php  echo $_SESSION['email']; ?>&laquo;</strong>Urithi Geolocation Service
                </a>
                <span class="right">
                    <a href="logout.php">
                        <strong>Logout here</strong>
                    </a>
                </span>
            </div><!--/ openmaps top bar -->
			
			<header>
			
				<h1><strong>Urithi Housing Cooperative Society Ltd‎</strong></h1>
				<h2>Geolocation of realty</h2>


			</header>
        </div>
		
    </body>
</html>