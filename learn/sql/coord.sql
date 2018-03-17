/**
have come up with a practical use for MySQL Stored Procedures and 
developed a very useful example for the sceptics. 
The following is a MySQL SP that calculates the distance between two ZIP codes 
– all you pass it is the zip codes! 
This code assumes you have a database of US ZIP Codes with their 
Longitudes and Latitudes.
**/

DELIMITER //
CREATE PROCEDURE `zipDist`(zipA INT, zipB INT)
BEGIN
 DECLARE latA DECIMAL(10,6);
 DECLARE lonA DECIMAL(10,6);
 DECLARE latB DECIMAL(10,6);
 DECLARE lonB DECIMAL(10,6);
 SELECT latitude, longitude INTO latA, lonA FROM zipcodes WHERE zip=zipA;
 SELECT latitude, longitude INTO latB, lonB FROM zipcodes WHERE zip=zipB;
 SELECT ACOS(SIN(RADIANS(latA)) * SIN(RADIANS(latB))  + COS(RADIANS(latA))
     * COS(RADIANS(latB))  * COS(RADIANS(lonB) - RADIANS(lonA)))
     * 3956 AS distance;
END//
DELIMITER ;

/**
Using this stored procedure in your code will save you 2 MySQL queries and a little bit of math in your code.
The following is a stored procedure to find all ZIP codes within a given redius, 
plus a bit of PHP5 code that calls the procedure using the mysqli extension.
**/
DELIMITER //
CREATE PROCEDURE `zipRad`(inZip INT, radius INT)
BEGIN
    DECLARE lat DOUBLE;
    DECLARE lon DOUBLE;
    SELECT latitude, longitude INTO lat, lon FROM zipcodes WHERE zip = inZip;
    SELECT zip FROM zipcodes WHERE (POW((69.1*(longitude - lon)
        *cos( lat /57.3)),2)+POW((69.1*(latitude - lat)),2))<(radius * radius);
END//
DELIMITER ;

/**
php code
***/
function zipRadius2($zip,$radius){
    $zipcon2 = mysqli_connect('127.0.0.1',"zipuser","zippass","zipdb")
        or die("Could not connect to DB: ".mysqli_connect_error());
    if($radius < 1 || $radius > 1000){return(false);}
    $query = "CALL zipRad($zip, $radius)";
    $result = mysqli_query($zipcon2, $query) or die(mysqli_error());
    $num = mysqli_num_rows($result);
    $i = 0;
    if($num != 0) {
        while($row = mysqli_fetch_assoc($result)) {
            $zipArray[$i] = $row["zip"];
            $i++;
        }
    }
 return $zipArray;
}