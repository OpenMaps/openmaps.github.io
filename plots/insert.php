<?php
#variables
$name = htmlspecialchars(trim($_POST['name']));
$email = htmlspecialchars(trim($_POST['email']));
$phone = htmlspecialchars(trim($_POST['phone']));
$lat = htmlspecialchars(trim($_POST['lat']));
$lng = htmlspecialchars(trim($_POST['lng']));
$token = htmlspecialchars(trim($_POST['token']));;

#Connect to postgreSQL database
$conn = new PDO('pgsql:host=localhost;dbname=postgres','postgres','root');
#ilike makes the search case insensitive - where f_r ilike '$x%'
$conn->exec("INSERT INTO public.sales (name, email, phone, lat, lng, token) VALUES ('$name', '$email', '$phone', '$lat', '$lng', '$token');");

$subject = "Welcome to the ...!";
$body = '
<html>
<head>
</head>
<body>
	<p>Thanks for booking a property with us</p>
	Your account information:<br>
	-------------------------<br>
	Email: '.$email.'<br>
	Details: '..'<br>
	-------------------------<br><br>
	Please visit the map for more.<br>
	Feel free to add book more from the map at any time!
</body>
</html>
';
$headers  = 'MIME-Version: 1.0' . "\r\n";
$headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";
$headers .= 'From: OpenMaps <noreply@openmaps.co.ke>' . "\r\n";
mail($email, $subject, $body, $headers, "-joshua@openmaps.co.ke");
$conn = NULL;

?>
