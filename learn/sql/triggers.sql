DROP TABLE IF EXISTS iventory;

create table if not exists inventory(
	inventory_id int(11) not null auto_increment,
	description text,
	price decimal(10,2),
	in_stock int(11),
	constraint `inventory_id_pkey` primary key (`inventory_id`)  
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists salespeople;

create table if not exists salespeople(
	salesperson_id int(11) not null auto_increment,
	first_name text,
	last_name text,
	constraint `salesperson_id_pkey` primary key (`salesperson_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists invoice;

create table if not exists invoice(
	line_id int(11) not null auto_increment,
	salesperson_id int(11),
	inventory_id int(11),
	quantity int(11),
	in_stock int(11),
	remain int (11),
	price decimal(10,2),
	discount decimal(10,2),
	pre_tax decimal(10,2),
	tax decimal(10,2),
	subtotal decimal(10,2),
	comment text,
	constraint `line_id_pkey` primary key (`line_id`),
	constraint `salesperson_id_fkey` foreign key (`salesperson_id`) references `salespeople` (`salesperson_id`)
	on delete restrict on update restrict,
	constraint `inventory_id_fkey` foreign key (`inventory_id`) references `inventory` (`inventory_id`)
	on delete restrict on update restrict
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


insert into salespeople (first_name,last_name) values('John','Wilson');
insert into salespeople (first_name,last_name) values('Terry','Johnson');
insert into salespeople (first_name,last_name) values('Mark','Philips');
insert into salespeople (first_name,last_name) values('Mary','Jones');
insert into salespeople (first_name,last_name) values('Frank','Smith');

insert into inventory (description, price, in_stock) values('Mousetrap',5.99,10);
insert into inventory (description, price, in_stock) values('Hammer',12.33,10);
insert into inventory (description, price, in_stock) values('Bird Seed',6.44,8);
insert into inventory (description, price, in_stock) values('Hacksaw',18.23,10);
insert into inventory (description, price, in_stock) values('Garden Hose',17.43,2);
insert into inventory (description, price, in_stock) values('Trash Can',14.45,2);
insert into inventory (description, price, in_stock) values('Nail 6d',0.07,188);
insert into inventory (description, price, in_stock) values('Nail 12d',0.28,78);

