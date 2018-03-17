create table bookstore 
   (id int not null auto_increment primary key,
    book varchar(50),
    author varchar(50),
    isbn varchar(50),
    price int);
/**
The SQL statements used to populate the bookstore table from:
**/
INSERT INTO bookstore (id,book,author,isbn,price) VALUES   
  (1,"Introduction to PHP","Mark User","3334-4424-334-3433",500)
INSERT INTO bookstore (id,book,author,isbn,price) VALUES 
  (2,"DHTML and CSS","Teague Sanders","4545-23-23-23-23232",1500)
INSERT INTO bookstore (id,book,author,isbn,price) VALUES 
  (3,"Introduction to PHP","Weeling Tom","4334-2323-23233-434",300)
INSERT INTO bookstore (id,book,author,isbn,price) VALUES 
  (4," Web design"," Weeling Tom"," 4334-2323-23233-434",600)
INSERT INTO bookstore (id,book,author,isbn,price) VALUES 
  (5," PHP 5"," Weeling Tom"," 444-87-67665-678678",600)
INSERT INTO bookstore (id,book,author,isbn,price) VALUES 
  (6," JavaServer Pages"," Tick Own"," 897-9898-987-099",800)

/**
Call Stored Procedures Using the MySQL Database Extension
a simple stored procedure. This one, called proc, 
selects all the fields in the bookstore table created earlier.
**/

CREATE PROCEDURE proc ( )
BEGIN
  SELECT * from bookstore;
END
/**
The following PHP script connects to the MySQL server, selects the books database, 
calls the proc stored procedure, 
which has no arguments, and outputs the result:
**/
<?php
 //Create the connecting to MySQL
 $con = mysql_connect('localhost','root','',false,65536);
 mysql_select_db('books');
 
 //Call the proc() procedure
 $result= mysql_query("CALL proc();")
 or die(mysql_error());
 
//Output the result
while($row = mysql_fetch_row($result))
{
 for($i=0;$i<=6;$i++){
   echo $row[$i]."<br>";
 }
echo "---";
}
//Close the connection
mysql_close($con);
?>
/**
Author's Note: Using the syntax $con = mysql_connect('localhost','root',''); will not work, 
because to return a result set from a stored procedure to PHP, 
you must use either the multiple-statements connect option or the multiple-results option (or both). 
If the routine does not return a result set, neither option is required.

The output is:

1---Introduction to PHP---Mark User---3334-4424-334-3433---500--------
2---DHTML and CSS---Teague Sanders---4545-23-23-23-23232---1500-------
3---Introduction to PHP---Weeling Tom---4334-2323-23233-434---300-----
4---Web design---Weeling Tom---4334-2323-23233-434---600---------
5---PHP 5---Weeling Tom---444-87-67665-678678---600---------
6---JavaServer Pages---Tick Own---897-9898-987-099---800---------

Here's a procedure example, named total_price, calculates the total of the price field from the bookstore table. 
It uses an OUT parameter to hold the total:
***/
CREATE PROCEDURE total_price ( OUT total int)
BEGIN
SELECT sum(price) into total from bookstore;
END
/**
The following PHP script calls the total_price procedure and displays the result using the OUT parameter total, which is an int:
**/
<?php
 $con = mysql_connect('localhost','root','',false,65536);
 mysql_select_db('books');
 
 //Calling the total_price stored procedure using the @t OUT parameter
 $result= mysql_query("CALL total_price(@t);")
 or die(mysql_error());
 
 //Listing the result
 $rs = mysql_query( 'SELECT @t' );
 while($row = mysql_fetch_row($rs))
 {
  echo 'The total price is = '.$row[0];
 }
mysql_close($con);
?>
/**
The output is:

The total price is = 4300

Calling Stored Functions Using the MySQL Extension

To illustrate making stored function calls here's a simple stored function:
**/
CREATE FUNCTION simple_operation (price int) RETURNS int(11)
RETURN price*1000
/**
The simple_operation function takes an integer argument, makes a simple calculation and returns an integer.
**/
<?php
 $con = mysql_connect('localhost','root','',false,65536);
 mysql_select_db('books');
 
 //Calling the simple_operation function
 $rs = mysql_query( 'SELECT simple_operation(5)' );
 while($row = mysql_fetch_row($rs))
 {
  echo 'The total price is = '.$row[0];
 }
mysql_close($con);
?>
/**

The output is:

The total price is = 5000
**/