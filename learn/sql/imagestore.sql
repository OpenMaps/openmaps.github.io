CREATE TABLE binary_data (
	id INT(4) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	description CHAR(50),
	bin_data LONGBLOB,
	filename CHAR(50),
	filesize CHAR(50),
	filetype CHAR(50)
);

<?php

// store.php3 - by Florian Dittmer <dittmer@gmx.net>
// Example php script to demonstrate the storing of binary files into
// a SQL database. More information can be found at http://www.phpbuilder.com/
?>

<html>
<head><title>Store binary data into SQL Database</title></head>
<body>

<?php
// code that will be executed if the form has been submitted:

if ($submit) {

    // connect to the database
    // (you may have to adjust the hostname,username or password)

    MYSQL_CONNECT("localhost","root","password");
    mysql_select_db("binary_data");

    $data = addslashes(fread(fopen($form_data, "r"), filesize($form_data)));

    $result=MYSQL_QUERY("INSERT INTO binary_data (description,bin_data,filename,filesize,filetype) ".
        "VALUES ('$form_description','$data','$form_data_name','$form_data_size','$form_data_type')");

    $id= mysql_insert_id();
    print "<p>This file has the following Database ID: <b>$id</b>";

    MYSQL_CLOSE();

} else {

    // else show the form to submit new data:
?>

    <form method="post" action="<?php echo $PHP_SELF; ?>" enctype="multipart/form-data">
    File Description:<br>
    <input type="text" name="form_description"  size="40">
    <input type="hidden" name="MAX_FILE_SIZE" value="1000000">
    <br>File to upload/store in database:<br>
    <input type="file" name="form_data"  size="40">
    <p><input type="submit" name="submit" value="submit">
    </form>

<?php

}

?>

</body>
</html>


<?php

// getdata.php3 - by Florian Dittmer <dittmer@gmx.net>
// Example php script to demonstrate the direct passing of binary data
// to the user. More info at http://www.phpbuilder.com
// Syntax: getdata.php3?id=<id>

if($id) {

    // you may have to modify login information for your database server:
    @MYSQL_CONNECT("localhost","root","password");

    @mysql_select_db("binary_data");

    $query = "select bin_data,filetype from binary_data where id=$id";
    $result = @MYSQL_QUERY($query);

    $data = @MYSQL_RESULT($result,0,"bin_data");
    $type = @MYSQL_RESULT($result,0,"filetype");

    Header( "Content-type: $type");
    echo $data;

};
?> 
