
START TRANSACTION
GO

INSERT INTO person
     (
        num           ,
        firstname     ,
        gender_code   ,
        birth_dttm    ,
        inactive_date ,
        lastname      
     ) 
VALUES
     (
        1 , 
        'Edward' , 
        'M' , 
        '1912-03-18 00:00:00' , 
        NULL , 
        'Ucator' 
     ) 
GO

INSERT INTO person
     (
        num           ,
        firstname     ,
        gender_code   ,
        birth_dttm    ,
        inactive_date ,
        lastname      
     ) 
VALUES
     (
        2 , 
        'Mary' , 
        'F' , 
        '1936-12-08 00:00:00' , 
        NULL , 
        'Meigh' 
     ) 
GO

INSERT INTO person
     (
        num           ,
        firstname     ,
        gender_code   ,
        birth_dttm    ,
        inactive_date ,
        lastname      
     ) 
VALUES
     (
        3 , 
        'Robert' , 
        'M' , 
        '1952-09-23 00:00:00' , 
        NULL , 
        'Frapples' 
     ) 
GO

COMMIT 
GO

