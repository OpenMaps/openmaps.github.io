
START TRANSACTION
GO

INSERT INTO address
     (
        person_num  ,
        type_code   ,
        street1     ,
        street2     ,
        city        ,
        state       ,
        postal_code 
     ) 
VALUES
     (
        1 , 
        'HM' , 
        '12305 Happy Lane' , 
        '' , 
        'Leeland' , 
        'NC' , 
        '21348' 
     ) 
GO

INSERT INTO address
     (
        person_num  ,
        type_code   ,
        street1     ,
        street2     ,
        city        ,
        state       ,
        postal_code 
     ) 
VALUES
     (
        1 , 
        'WK' , 
        '99 Busy Rd' , 
        '' , 
        'Leeland' , 
        'NC' , 
        '21345' 
     ) 
GO

INSERT INTO address
     (
        person_num  ,
        type_code   ,
        street1     ,
        street2     ,
        city        ,
        state       ,
        postal_code 
     ) 
VALUES
     (
        3 , 
        'HM' , 
        '123 Sunny Blvd' , 
        '' , 
        'Scranton' , 
        'PA' , 
        '99999' 
     ) 
GO

COMMIT 
GO

