create database bookmarks;
use bookmarks;

create table user(
	first_name varchar(100) not null,
	last_name varchar(100) not null,
	id_number int unsigned not null,
	username varchar(16) not null primary key,
	passwd char(40) not null,
	email varchar(100) not null
	);
	
create table bookmark (
	username varchar(16) not null,
	bm_URL varchar(255) not null,
	index (username),
	index (bm_URL),
	primary key(username, bm_URL)
	);
