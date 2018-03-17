CREATE TABLE IF NOT EXISTS person
     (
       num            INT(11)      NOT NULL  DEFAULT 0  , 
       firstname      VARCHAR(20)      NULL             , 
       gender_code    CHAR(1)          NULL             , 
       birth_dttm     DATETIME         NULL             , 
       inactive_date  DATETIME         NULL             , 
       lastname       VARCHAR(30)      NULL             , 
       PRIMARY KEY (num) 
     ) ENGINE = MYISAM

GO


CREATE TABLE IF NOT EXISTS phone
     (
       person_num     INT(11)   NOT NULL  DEFAULT 0  , 
       type_code      CHAR(3)   NOT NULL             , 
       area_code      CHAR(3)       NULL             , 
       exchange       CHAR(3)       NULL             , 
       extension      CHAR(4)       NULL             , 
       inactive_date  DATETIME      NULL             , 
       PRIMARY KEY (person_num, type_code) 
     ) ENGINE = MYISAM

GO

ALTER TABLE phone ADD 
      CONSTRAINT FK_phone_person_num
      FOREIGN    KEY (person_num)
      REFERENCES person(num)
GO 


CREATE TABLE IF NOT EXISTS address
     (
       person_num   INT(11)   NOT NULL  DEFAULT 0  , 
       type_code    CHAR(4)   NOT NULL             , 
       street1      CHAR(30)      NULL             , 
       street2      CHAR(30)      NULL             , 
       city         CHAR(30)      NULL             , 
       state        CHAR(2)       NULL             , 
       postal_code  CHAR(10)      NULL             , 
       PRIMARY KEY (person_num, type_code) 
     ) ENGINE = MYISAM

GO

ALTER TABLE address ADD 
      CONSTRAINT FK_address_person_num
      FOREIGN    KEY (person_num)
      REFERENCES person(num)
GO
