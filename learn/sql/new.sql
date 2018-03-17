
DELIMITER $$
DROP PROCEDURE IF EXISTS `tracedbe`.`process_journal`$$
CREATE PROCEDURE  `tracedbe`.`process_journal`
(
IN manuscript_ID INT,
OUT Status enum,
OUT Title VARCHAR(15)
)
BEGIN
SELECT title, status INTO Title, Status FROM manuscripts WHERE manuscript_id = manuscript_ID;
END $$
DELIMITER ;

/**try this**/

delimiter //

create procedure proc_journal (
	in manuscript_ID int(11),
	in author_ID int(11),
	inout mstatus enum,
	inout mtitle VARCHAR(300)
)
BEGIN
select `manuscript_id`,`title`,`status` into manuscript_ID,mtitle,mstatus from manuscripts where manuscript_id  = manuscript_ID;

select `author_id` into author_ID 
from authors where author_id = author_ID;

if (status = 11)
	set manuscript_id = manuscript_ID;
	set title = mtitle;
	set author_id = author_ID;
	set comment = 'INCLUDED';
else
	set comment = 'NOT INCLUDED';
END 
//
delimiter ;