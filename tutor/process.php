<?php
$sname = "localhost";
$uname = "openmaps_user";
$pword = "open2015";
$dbname = "openmaps_originis";

// create a variable
$name=$_POST['name'];
$message=$_POST['message'];
$email=$_POST['email'];

// Create connection
$conn = new mysqli($sname, $uname, $pword, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 

$sql = "INSERT INTO originis (name, message, email)
VALUES ($name, $message, $email)";

if ($conn->query($sql) === TRUE) {
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>