drop schema if exists openkeja;
create schema openkeja;
use openkeja;

drop table if exists contacts;

create table if not exists contacts (
	contacts_id int(12) not null auto_increment,
	agent_no char(20) not null,
	agent_email varchar(20),
	owner_no char(20),
	owner_email varchar(20),
	constraint contacts_pkey primary key (contacts_id)
) engine=innodb default charset=utf8;

drop table if exists hse_status;

create table if not exists hse_status (
	status_id int(12) not null auto_increment,
	status enum ('rent', 'sale'),
	type enum ('apartment','office','house','warehouse'),
	constraint hse_status_pkey primary key (status_id)
)engine =innodb default charset=utf8;

drop table if exists pics;

create table if not exists pics (
	pics_id int(12) not null auto_increment,
	imag varchar (255) not null,
	clips varchar (255),
	constraint pics_id_pkey primary key (pics_id)
)engine=innodb default charset=utf8;

drop table if exists keja;

create table if not exists keja (
	keja_id int(12) not null auto_increment,
	status_id int(12) not null,
	contacts_id int(12) not null,
	pics_id int(12) not null,
	name varchar (100) not null,
	terms enum ('weekly','monthly','yearly'),
	min_price decimal (10,2) not null,
	max_price decimal (10,2) not null,
	bedrums int(12) not null,

	lat decimal (15,14) not null,
	llong decimal (15,14) not null,
	comments varchar (255),
	constraint keja_id_pkey primary key (keja_id),
	constraint keja_hse_status_fkey foreign key (status_id) references hse_status (status_id)
	on update cascade on delete cascade,
	constraint keja_contacts_fkey foreign key (contacts_id) references contacts (contacts_id)
	on update cascade on delete cascade,
	constraint keja_pics_fkey foreign key (pics_id) references pics (pics_id)
	on update cascade on delete cascade
)engine=innodb default charset=utf8;
	
	
	
	
