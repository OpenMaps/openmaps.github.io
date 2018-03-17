DROP PROCEDURE IF EXISTS `sp_students_SELECT_byPK` 

CREATE PROCEDURE `sp_students_SELECT_byPK`
     (
        IN   p_student_id INT(11), 
        OUT  p_password VARCHAR(15), 
        OUT  p_active_flg TINYINT(4), 
        OUT  p_lastname VARCHAR(30), 
        OUT  p_firstname VARCHAR(20), 
        OUT  p_gender_code VARCHAR(1), 
        OUT  p_birth_dttm DATETIME      
     )
BEGIN 

    SELECT password, 
           active_flg, 
           lastname, 
           firstname, 
           gender_code, 
           birth_dttm           
    INTO   p_password, 
           p_active_flg, 
           p_lastname, 
           p_firstname, 
           p_gender_code, 
           p_birth_dttm                  
    FROM   students
    WHERE  student_id = p_student_id; 

END 
/**
IN means when this stored procedure is called, this variable should be passed with a value. 
OUT means after the stored procedure executes, it will set the OUT variables with a value that can then be retrieved. 
You can also have INOUT variables
The blulk of the code for the stored procedure goes in the BEGIN to END block

Cursors

You use cursors to fetch data and execute some action for each result returned.

For instance, you would use a cursor to fetch all clients and, 
for each client retrurned, retrieve his/her neighbours given some conditions 
(much like a for loop in regular programming languages)
-------------------------
Executing a Stored Procedure
;;;;;;;;;;;;;;;;;;;;;;
CALL my_sp;
---------------------------
Simplest possible example in MySQL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELIMITER $$
CREATE PROCEDURE sp_example1 () 
BEGIN
  SELECT * from users; 
END
----------------------------
Variables and selecting values into variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELIMITER $$
CREATE PROCEDURE sp_example2()
BEGIN
DECLARE my_var VARCHAR(511); 

  SELECT username 
  FROM users 
  WHERE id=4 
  INTO my_var;
  -- my_var now holds your user's name
  -- you could insert it into another table, for instance.

END
--------------------------------------------
Procedure parameters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELIMITER $$
CREATE PROCEDURE sp_example3(
	IN vr_name VARCHAR(100)
	)
BEGIN

  SELECT username 
  FROM users u
  WHERE u.username = vr_name;

END
-------------------------------------------
Cursors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CREATE PROCEDURE sp_example4()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE vr_name VARCHAR(100);
    DECLARE cur1 CURSOR FOR SELECT username FROM users;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    -- now we open the cursor
    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO vr_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- now do something with the return, vr_name.
    END LOOP;
    CLOSE cur1;
END;
------------------------------------------------
**/

