CREATE DATABASE `test`;

DROP TABLE IF EXISTS `test`.`users`;
CREATE TABLE  `test`.`users` (
`users_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
`first_name` VARCHAR(100) NOT NULL,
`last_name` VARCHAR(100) NOT NULL,
PRIMARY KEY  (`users_id`)
) ENGINE=INNODB DEFAULT CHARSET=latin1;


INSERT INTO `test`.`users` VALUES (NULL, ‘Joey’, ‘Rivera’), (NULL, ‘John’, ‘Doe’);

DELIMITER $$
DROP PROCEDURE IF EXISTS `test`.`get_user`$$
CREATE PROCEDURE  `test`.`get_user`
(
IN userId INT,
OUT firstName VARCHAR(100),
OUT lastName VARCHAR(100)
)
BEGIN
SELECT first_name, last_name
INTO firstName, lastName
FROM users
WHERE users_id = userId;
END $$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `test`.`get_users`$$
CREATE PROCEDURE  `test`.`get_users`()
BEGIN
SELECT *
FROM users;
END $$
DELIMITER ;


<?php
// MYSQL
$mysql = mysql_connect(‘localhost’, ‘admin’, ‘root’,,false,65536);
mysql_select_db(‘test’, $mysql);

print ‘<h3>MYSQL: simple select</h3>’;
$rs = mysql_query( ‘SELECT * FROM users;’ );
while($row = mysql_fetch_assoc($rs))
{
debug($row);
}

print ‘<h3>MYSQL: calling sp with out variables</h3>’;
$rs = mysql_query( ‘CALL get_user(1, @first, @last)’ );
$rs = mysql_query( ‘SELECT @first, @last’ );
while($row = mysql_fetch_assoc($rs))
{
debug($row);
}

print ‘<h3>MYSQL: calling sp returning a recordset – doesn\’t work</h3>’;
$rs = mysql_query( ‘CALL get_users()’ );
while($row = mysql_fetch_assoc($rs))
{
debug($row);
}

// MYSQLI
$mysqli = new mysqli(‘localhost’, ‘example’, ‘example’, ‘test’);

print ‘<h3>MYSQLI: simple select</h3>’;
$rs = $mysqli->query( ‘SELECT * FROM users;’ );
while($row = $rs->fetch_object())
{
debug($row);
}

print ‘<h3>MYSQLI: calling sp with out variables</h3>’;
$rs = $mysqli->query( ‘CALL get_user(1, @first, @last)’ );
$rs = $mysqli->query( ‘SELECT @first, @last’ );
while($row = $rs->fetch_object())
{
debug($row);
}

print ‘<h3>MYSQLI: calling sp returning a recordset</h3>’;
$rs = $mysqli->query( ‘CALL get_users()’ );
while($row = $rs->fetch_object())
{
debug($row);
}

// PDO
$pdo = new PDO(‘mysql:dbname=test;host=127.0.0.1′, ‘example’, ‘example’);

print ‘<h3>PDO: simple select</h3>’;
foreach($pdo->query( ‘SELECT * FROM users;’ ) as $row)
{
debug($row);
}

print ‘<h3>PDO: calling sp with out variables</h3>’;
$pdo->query( ‘CALL get_user(1, @first, @last)’ );
foreach($pdo->query( ‘SELECT @first, @last’ ) as $row)
{
debug($row);
}

print ‘<h3>PDO: calling sp returning a recordset</h3>’;
foreach($pdo->query( ‘CALL get_users()’ ) as $row)
{
debug($row);
}

function debug($o)
{
print ‘<pre>’;
print_r($o);
print ‘</pre>’;
}
?>