
drop table if exists artists;
create table if not exists artists (
	artist_id int(3) unsigned not null auto_increment,
	first_name varchar(20) default null,
	middle_name varchar(20) default null,
	last_name varchar(30) not null,
	constraint artist_id_pkey primary key (artist_id),
	key full_name (last_name, first_name)
)engine=myisam default charset=utf8;

drop table if exists prints;
create table if not exists prints (
	print_id int(4) unsigned not null auto_increment,
	artist_id int(3) unsigned not null,
	print_name varchar(60) not null,
	price decimal(6,2) not null,
	size varchar(60) default null,
	description varchar(30) not null,
	image_name varchar(30) not null,
	constraint print_id_pkey primary key (print_id),
	key artist_id (artist_id),
	key print_name (print_name),
	key price (price)
)engine=myisam default charset=utf8;

drop table if exists customers;
create table if not exists customers (
	customer_id int(5) unsigned not null auto_increment,
	email varchar(40) not null,
	pass char(40) not null,
	constraint customer_id_pkey primary key(customer_id),
	key email_pass (email,pass)
)engine=innodb default charset=utf8;

drop table if exists orders;
create table if not exists orders (
	order_id int(10) unsigned not null auto_increment,
	customer_id int(5) unsigned not null,
	total decimal(10,2) not null,
	order_date timestamp not null,
	constraint order_id_pkey primary key (order_id),
	key customer_id (customer_id),
	key order_date (order_date)
)engine=innodb default charset=utf8;

drop table if exists order_contents;
create table if not exists order_contents (
	oc_id int(10) unsigned not null auto_increment,
	order_id int(10) unsigned not null,
	print_id int(4) unsigned not null,
	quantity tinyint unsigned not null default 1,
	price decimal(6,2) not null,
	ship_date datetime default null,
	constraint order_contents_pkey primary key (oc_id),
	key order_id (order_id),
	key print_id  (print_id),
	key ship_date (ship_date)
)engine=innodb default charset=utf8;
	