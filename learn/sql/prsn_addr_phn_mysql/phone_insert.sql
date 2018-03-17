
START TRANSACTION
GO

INSERT INTO phone
     (
        person_num ,
        type_code  ,
        area_code  ,
        exchange   ,
        extension  
     ) 
VALUES
     (
        2 , 
        'CEL' , 
        '555' , 
        '121' , 
        '8900' 
     ) 
GO

INSERT INTO phone
     (
        person_num ,
        type_code  ,
        area_code  ,
        exchange   ,
        extension  
     ) 
VALUES
     (
        2 , 
        'HM' , 
        '888' , 
        '555' , 
        '8701' 
     ) 
GO

INSERT INTO phone
     (
        person_num ,
        type_code  ,
        area_code  ,
        exchange   ,
        extension  
     ) 
VALUES
     (
        3 , 
        'HM' , 
        '818' , 
        '555' , 
        '5555' 
     ) 
GO

INSERT INTO phone
     (
        person_num ,
        type_code  ,
        area_code  ,
        exchange   ,
        extension  
     ) 
VALUES
     (
        3 , 
        'WK' , 
        '819' , 
        '555' , 
        '5559' 
     ) 
GO

COMMIT 
GO

