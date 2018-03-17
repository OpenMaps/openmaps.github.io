create database btw;
use btw;

create table markers(
	id int not null auto_increment primary key,
	name varchar(60) not null,
	address varchar(80) not null,
	lat float(10,2) not null,
	lng float(10,2) not null,
	type varchar(30) not null
	) ENGINE = MYISAM;