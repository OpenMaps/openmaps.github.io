--  ***************************************************************************
--  *   Copyright (C) 2012, Paul Lutus                                        *
--  *                                                                         *
--  *   This program is free software; you can redistribute it and/or modify  *
--  *   it under the terms of the GNU General Public License as published by  *
--  *   the Free Software Foundation; either version 2 of the License, or     *
--  *   (at your option) any later version.                                   *
--  *                                                                         *
--  *   This program is distributed in the hope that it will be useful,       *
--  *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
--  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
--  *   GNU General Public License for more details.                          *
--  *                                                                         *
--  *   You should have received a copy of the GNU General Public License     *
--  *   along with this program; if not, write to the                         *
--  *   Free Software Foundation, Inc.,                                       *
--  *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
--  ***************************************************************************

create database if not exists tutorial;
use tutorial;

-- drop table if exists debug;

-- create table if not exists debug (
--   debug text
-- );

drop table if exists purchases;

create table if not exists purchases (
  Item text not null,
  Quan integer not null,
  Price decimal(10,2) not null,
  `Disc %` decimal(10,2),
  PreTax decimal(10,2),
  Tax decimal(10,2),
  Subtotal decimal(10,2),
  Total decimal(10,2),
  pk integer not null auto_increment,
  primary key (`pk`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8; 

drop trigger if exists update_purchases;

drop trigger if exists insert_purchases;

drop procedure if exists process_purchase;

delimiter |

create procedure process_purchase (
  in quantity integer,
  in price decimal(10,2),
  inout discount decimal(10,2),
  inout beforetax decimal(10,2),
  inout salestax decimal(10,2),
  inout subtotal decimal(10,2),
  out total decimal(10,2),
  in  newpk integer
  )
BEGIN
  set discount = if(quantity >= 10,10,0);
  set beforetax = price * quantity * 1 - (discount / 100);
  set salestax = beforetax * 0.085;
  set subtotal = beforetax + salestax;
  set @prior_total = 0;
  if(newpk = 0) then
    select temptable.Total into @prior_total from tutorial.purchases as temptable 
	where pk != 0 order by pk desc limit 1;
  else
    select temptable.Total into @prior_total from tutorial.purchases as temptable 
	where pk < newpk order by pk desc limit 1;
  end if;
  set total = subtotal + @prior_total;
END|

CREATE TRIGGER `update_purchases`
before update ON `purchases`
for each row
BEGIN
  call process_purchase(
	  new.Quan,
	  new.Price,
	  new.`Disc %`,
	  new.PreTax,
	  new.Tax,
	  new.Subtotal,
	  new.Total,
	  new.pk
  );
END|

CREATE TRIGGER `insert_purchases`
before insert ON `purchases`
for each row
BEGIN
  call process_purchase(
	  new.Quan,
	  new.Price,
	  new.`Disc %`,
	  new.PreTax,
	  new.Tax,
	  new.Subtotal,
	  new.Total,
	  new.pk
  );
END|

delimiter ;

-- insert some sample data

insert into purchases (Item,Quan,Price) values('Gadgets',10,5.98);
insert into purchases (Item,Quan,Price) values('Widgets',8,4.33);
insert into purchases (Item,Quan,Price) values('Tools',16,32.88);
insert into purchases (Item,Quan,Price) values('Hardware',34,2.45);
insert into purchases (Item,Quan,Price) values('Mousetraps',22,5.93);

-- update purchases set Total = 0;

-- select * from debug;
create function formatAddress (
	@street as varchar (50),
	@city as varchar(50),
	@state as varchar(50),
	@zip as varchar(50)
	)
	RETURNS varchar(255)
	AS
	BEGIN 
		IF (@street IS NULL OR
		   @city IS NULL OR
		   @state IS NULL OR 
		   @zip IS NULL)
		   
		   RETURN 'Incomplete Address'
		  
		SET @state =
		CASE @state 
			WHEN 'LA' THEN 'Louisiana'
			WHEN 'NY' THEN 'New York'
			WHEN 'CA' THEN 'California'
		END
	RETURN @street +' '+@city+','+@state+''+@zip
	
END

--test
select formatAddress ('100 Main','Buff','NY','32993')

select fname, lname, formatAddress (address, city, state, zip) 
from authors
where formatAddress(address, city, state, zip) = 'Incomplete Address'
--or 
order by formatAddress(address, city, state, zip)

--function
create function authorByStatus (@isActive int)
returns @AuthorsTable Table(
	fname varchar (50) not null,
	lname varchar (50) not null,
	phone varchar (50) null,
	address varchar (50) null,
	city varchar (50) null,
	state varchar (50) null,
	zip varchar (50) null,
	Active int null
	)
	AS
	BEGIN
	
	insert into @AuthorsTable
		select * 
		from authors 
		where Active = @isActive
	Return;
	
END

---test
select * from AuthorsByStatus (1)

---triggers
--after trigger===executes immediately after insert, update or delete stmt
---and allows stmt to execute, then takes over
create trigger `categoryDeactivation`
ON `category`
AFTER UPDATE
AS
BEGIN 
	DECLARE @isActive AS bit
	
	select @isActive = Active
	from Inserted
	
	IF (@isActive = 0)
		UPDATE product
		SET Active = 0
		WHERE cateId IN (select cateId from Inserted)
END

	