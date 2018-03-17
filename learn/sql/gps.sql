CREATE DATABASE gps_tracking_db
ENCODING = 'UTF8'
TEMPLATE = template0
LC_COLLATE = 'C'
LC_CTYPE = 'C';

CREATE SCHEMA main;

COMMENT ON SCHEMA main IS 'Schema that stores all the GPS tracking core 
data.';

CREATE TABLE main.gps_data(
	gps_data_id serial,
	gps_sensors_code character varying,
	line_no integer,
	utc_date date,
	utc_time time without time zone,
	lmt_date date,
	lmt_time time without time zone,
	ecef_x integer,
	ecef_y integer,
	ecef_z integer,
	latitude double precision,
	longitude double precision,
	height double precision,
	dop double precision,
	nav character varying(2),
	validated character varying(3),
	sats_used integer,
	ch01_sat_id integer,
	ch01_sat_cnr integer,
	ch02_sat_id integer,
	ch02_sat_cnr integer,
	ch03_sat_id integer,
	ch03_sat_cnr integer,
	ch04_sat_id integer,
	ch04_sat_cnr integer,
	ch05_sat_id integer,
	ch05_sat_cnr integer,
	ch06_sat_id integer,
	ch06_sat_cnr integer,
	ch07_sat_id integer,
	ch07_sat_cnr integer,
	ch08_sat_id integer,
	ch08_sat_cnr integer,
	ch09_sat_id integer,
	ch09_sat_cnr integer,
	ch10_sat_id integer,
	ch10_sat_cnr integer,
	ch11_sat_id integer,
	ch11_sat_cnr integer,
	ch12_sat_id integer,
	ch12_sat_cnr integer,
	main_vol double precision,
	bu_vol double precision,
	temp double precision,
	easting integer,
	northing integer,
	remarks character varying
);
COMMENT ON TABLE main.gps_data
IS 'Table that stores raw data as they come from the sensors (plus the ID of
the sensor).';


ALTER TABLE main.gps_data 
	ADD CONSTRAINT gps_data_pkey PRIMARY KEY(gps_data_id);
	
ALTER TABLE main.gps_data 
	ADD COLUMN insert_timestamp timestamp with time zone
	DEFAULT now();
	
ALTER TABLE main.gps_data
	ADD CONSTRAINT unique_gps_data_record UNIQUE(gps_sensors_code, line_no);
	
	
/*import the GPS data sets.*/
COPY main.gps_data(
	gps_sensors_code, line_no, utc_date, utc_time, lmt_date, lmt_time, ecef_x,
	ecef_y, ecef_z, latitude, longitude, height, dop, nav, validated, sats_used,
	ch01_sat_id, ch01_sat_cnr, ch02_sat_id, ch02_sat_cnr, ch03_sat_id, 
	ch03_sat_cnr, ch04_sat_id, ch04_sat_cnr, ch05_sat_id, ch05_sat_cnr, 
	ch06_sat_id, ch06_sat_cnr, ch07_sat_id, ch07_sat_cnr, ch08_sat_id, 
	ch08_sat_cnr, ch09_sat_id, ch09_sat_cnr, ch10_sat_id, ch10_sat_cnr, 
	ch11_sat_id, ch11_sat_cnr, ch12_sat_id, ch12_sat_cnr, main_vol, bu_vol, 
	temp, easting, northing, remarks)
FROM
	'/var/www/RealTime/tracking_db/data/sensors_data/GSM01438.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';')


/*import the GPS data sets.*/	
COPY main.gps_data(
	gps_sensors_code, line_no, utc_date, utc_time, lmt_date, lmt_time, ecef_x,
	ecef_y, ecef_z, latitude, longitude, height, dop, nav, validated, sats_used,
	ch01_sat_id, ch01_sat_cnr, ch02_sat_id, ch02_sat_cnr, ch03_sat_id, 
	ch03_sat_cnr, ch04_sat_id, ch04_sat_cnr, ch05_sat_id, ch05_sat_cnr, 
	ch06_sat_id, ch06_sat_cnr, ch07_sat_id, ch07_sat_cnr, ch08_sat_id, 
	ch08_sat_cnr, ch09_sat_id, ch09_sat_cnr, ch10_sat_id, ch10_sat_cnr, 
	ch11_sat_id, ch11_sat_cnr, ch12_sat_id, ch12_sat_cnr, main_vol, bu_vol, 
	temp, easting, northing, remarks)
FROM
	'/var/www/RealTime/tracking_db/data/sensors_data/GSM01511.csv'	WITH (FORMAT csv, HEADER, DELIMITER ';');
	
	
/*import the GPS data sets.*/	
COPY main.gps_data(
	gps_sensors_code, line_no, utc_date, utc_time, lmt_date, lmt_time, ecef_x,
	ecef_y, ecef_z, latitude, longitude, height, dop, nav, validated, sats_used,
	ch01_sat_id, ch01_sat_cnr, ch02_sat_id, ch02_sat_cnr, ch03_sat_id, 
	ch03_sat_cnr, ch04_sat_id, ch04_sat_cnr, ch05_sat_id, ch05_sat_cnr, 
	ch06_sat_id, ch06_sat_cnr, ch07_sat_id, ch07_sat_cnr, ch08_sat_id, 
	ch08_sat_cnr, ch09_sat_id, ch09_sat_cnr, ch10_sat_id, ch10_sat_cnr, 
	ch11_sat_id, ch11_sat_cnr, ch12_sat_id, ch12_sat_cnr, main_vol, bu_vol, 
	temp, easting, northing, remarks)
FROM
	'/var/www/RealTime/tracking_db/data/sensors_data/GSM01512.csv' WITH (FORMAT csv, HEADER, DELIMITER ';');
	
	
/*If PostgreSQL complains that date is out of range, check the standard date
format used by your database:*/
SHOW datestyle;

/*If it is not ‘ISO, DMY’ (Day, Month, Year), then you have to set the date
format in the same session of the COPYstatement:*/
SET SESSION datestyle = "ISO, DMY";

/*To determine the time zone set in your database you can run*/
SHOW time zone;

/*You can run the following SQL codes to explore how the database manages different
specifications of the time and date types:*/
SELECT
	'2012-09-01'::DATE AS date1, 
	'12:30:29'::TIME AS time1,
	('2012-09-01' || ' ' || '12:30:29') AS timetext;
	
/*In the result below, the data type returned by PostgreSQL are respectively date, time
without time zone and text.*/
date1       |   time1  | timetext 
------------+----------+---------------------
2015-09-01  | 12:30:29 | 2015-09-01 12:30:29

/*Here you have some examples of how to create a timestamp data type in PostgreSQL:*/
SELECT
	'2012-09-01'::DATE + '12:30:29'::TIME AS timestamp1,
	('2012-09-01' || ' ' || '12:30:29')::TIMESTAMP WITHOUT TIME ZONE AS 
	timestamp2,
	'2012-09-01 12:30:29+00'::TIMESTAMP WITH TIME ZONE AS timestamp3;
	
/*In this case, the data type of the first two fields returned is timestamp without time zone,
while the third one is timestamp with time zone (the output can vary according to the
default time zone of your database server):*/
  timestamp1         |     timestamp2      |  timestamp3 
---------------------+---------------------+------------------------
2015-09-01 12:30:29  | 2015-09-01 12:30:29 | 2015-09-01 12:30:29+00

/*You can see what happens when you specify the time zone and when you ask for the
timestamp with time zone from a timestamp without time zone (the result will depend on
the default time zone of your database server):*/
SELECT
	'2012-09-01 12:30:29 +0'::TIMESTAMP WITH TIME ZONE AS timestamp1, 
	('2012-09-01'::DATE + '12:30:29'::TIME) AT TIME ZONE 'utc' AS timestamp2,
	('2012-09-01 12:30:29'::TIMESTAMP WITHOUT TIME ZONE)::TIMESTAMP WITH TIME 
	ZONE AS timestamp3;
	
/*The result for a server located in Italy (time zone +02 in summer time) is*/
       timestamp1       |        timestamp2      | timestamp3 
------------------------+------------------------+------------------------
2015-09-01 14:30:29+03  | 2015-09-01 14:30:29+03 |  2015-09-01 12:30:29+03

/*epoch (number of seconds from 1st January 1970*/

/*You can easily extract part of the timestamp, including epoch(number of seconds from
1st January 1970, a format that in some cases can be convenient as it expresses a timestamp as an integer):*/
SELECT
	EXTRACT (MONTH FROM '2015-09-01 12:30:29 +0'::TIMESTAMP WITH TIME ZONE) AS	month1,
	EXTRACT (EPOCH FROM '2015-09-01 12:30:29 +0'::TIMESTAMP WITH TIME ZONE) AS	epoch1;
	
/*The expected result is*/
 month1 | epoch1 
--------+------------
   9    | 1441110629
/*Coordinated Universal Time (UTC) is the primary time standard by which the world regulates
clocks and time. For most purposes, UTC is synonymous with GMT, but GMT is no longer
precisely defined by the scientific community. */	

/*In this last example, you set a specific time zone (EST—Eastern Standard Time, 
which has an offset of -5 h compared to UTC) for the current session*/
SET timezone TO 'EST';
SELECT now() AS time_in_EST_zone;

SET timezone TO 'UTC';
SELECT now() AS time_in_UTC_zone;


/*You can compare the results of the two queries to see the difference. To permanently
change the reference time zone to UTC, you have to edit the file postgresql.conf. In most
of the applications related to movement ecology, this is probably the best option as GPS
uses this reference.*/

/*In the original GPS data file, no timestamp field is present. Although the table
main.gps_data is designed to store data as they come from the sensors, it is
convenient to have an additional field where date and time are combined and
where the correct time zone is set (in this case UTC). */

ALTER TABLE main.gps_data 
	ADD COLUMN acquisition_time timestamp with time zone;
	
UPDATE main.gps_data 
	SET acquisition_time = (utc_date + utc_time) AT TIME ZONE 'UTC';
	
/*indexes are data structures that improve the speed of data retrieval operations on a database table at
the cost of slower writes and the use of more storage space. 
Database indexes work in a similar way to a book’s table of contents: you have to add an extra page and
update it whenever new content is added, but then searching for specific sections will be much faster.
You have to decide on which fields you create indexes for by considering what kind of query will 
be performed most often in the database.*/

CREATE INDEX acquisition_time_index
	ON main.gps_data USING btree (acquisition_time );
	
CREATE INDEX gps_sensors_code_index
	ON main.gps_data USING btree (gps_sensors_code);
	
/*As a simple example, you can now retrieve data using specific selection criteria
(GPS positions in May (5) from the sensor GSM01438). Let us retrieve data from the
collar ‘GSM01512’ during the month of May (whatever the year), and order them
by their acquisition time:*/

SELECT
	gps_data_id AS id, 
	gps_sensors_code AS sensor_id, 
	latitude, 
	longitude, 
	acquisition_time
FROM
	main.gps_data
WHERE
	gps_sensors_code = 'GSM01512' and EXTRACT(MONTH FROM acquisition_time) = 5
ORDER BY 
	acquisition_time
LIMIT 10;

/*The first records (LIMIT 10 returns just the first 10 records; you can remove this
condition to have the full list of records) of the result of this query are*/
   id  | sensor_id | latitude | longitude | acquisition_time 
-------+-----------+----------+-----------+------------------------
 11906 | GSM01512  | 46.00563 |  11.05291 | 2006-05-01 00:01:01+00
 11907 | GSM01512  | 46.00630 |  11.05352 | 2006-05-01 04:02:54+00
 11908 | GSM01512  | 46.00652 |  11.05326 | 2006-05-01 08:01:03+00
 11909 | GSM01512  | 46.00437 |  11.05536 | 2006-05-01 12:02:40+00
 11910 | GSM01512  | 46.00720 |  11.05297 | 2006-05-01 16:01:23+00
 11911 | GSM01512  | 46.00709 |  11.05339 | 2006-05-01 20:00:53+00
 11912 | GSM01512  | 46.00723 |  11.05346 | 2006-05-02 00:00:54+00
 11913 | GSM01512  | 46.00649 |  11.05251 | 2006-05-02 04:01:54+00
 11914 | GSM01512  |          |           | 2006-05-02 08:03:06+00
 11915 | GSM01512  | 46.00687 |  11.05386 | 2006-05-02 12:01:24+00

/*As an example, you create here a user (login basic_user, password basic_user)
and grant read permission for the main.gps_data table and all the objects that will
be created in the main schema in the future:*/
CREATE ROLE basic_user LOGIN
	PASSWORD 'basic_user' 
	NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT SELECT ON ALL TABLES 
	IN SCHEMA main 
	TO basic_user;
ALTER DEFAULT PRIVILEGES 
	IN SCHEMA main 
	GRANT SELECT ON TABLES 
	TO basic_user;
	
/*Setting a permission policy in a complex multi-user environment requires
an appropriate definition of data access at different levels and it is out of the scope
of this guide. You can find more information on the official PostgreSQL
documentation*/

/*Export Data and Backup*/
COPY (
SELECT gps_data_id, gps_sensors_code, latitude, longitude, acquisition_time, insert_timestamp 
	FROM main.gps_data) 
TO
	'/var/www/RealTime/trackingDB_dump/export_test1.csv' WITH (FORMAT csv, HEADER, DELIMITER ';');
	
/*pg_dump.exe: extracts a PostgreSQL database or part of the database into a
script file or other archive file;
pg_restore.exe is used to restore the database;
pg_dumpall.exe: extracts a PostgreSQL database cluster (i.e. all the databases
created inside the same installation of PostgreSQL) into a script file (e.g.
including database setting, roles).*/

/*Another possibility is to use the pgAdmin interface: in the SQL console select
‘Query’/‘Execute to file’.*/

CREATE TABLE main.gps_sensors(
	gps_sensors_id integer,
	gps_sensors_code character varying NOT NULL,
	purchase_date date,
	frequency double precision,
	vendor character varying,
	model character varying,
	sim character varying,
	CONSTRAINT gps_sensors_pkey 
	PRIMARY KEY (gps_sensors_id ),
	CONSTRAINT gps_sensor_code_unique 
	UNIQUE (gps_sensors_code)
);
COMMENT ON TABLE main.gps_sensors
IS 'GPS sensors catalog.';

ALTER TABLE main.gps_sensors 
	ADD COLUMN insert_timestamp timestamp with time zone DEFAULT now();
	
COPY main.gps_sensors(
	gps_sensors_id, gps_sensors_code, purchase_date, frequency, vendor, model, sim)
FROM
	'/var/www/RealTime/tracking_db/data/sensors/gps_sensors.csv' WITH (FORMAT csv, DELIMITER ';');
	
/*At this stage, you have defined the list of GPS sensors that exist in your
database. To be sure that you will never have GPS data that come from a GPS
sensor that does not exist in the database, you apply a foreign key between
main.gps_data and main.gps_sensors. 
Foreign keys physically translate the concept of relations among tables.*/

ALTER TABLE main.gps_data
	ADD CONSTRAINT gps_data_gps_sensors_fkey 
	FOREIGN KEY (gps_sensors_code)
	REFERENCES main.gps_sensors (gps_sensors_code) 
	MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

/*This setting says that in order to delete a record in main.gps_sensors, you first
have to delete all the associated records in main.gps_data. From now on, before
importing GPS data from a sensor, you have to create the sensor’s record in the
main.gps_sensors table.
You can add other kinds of constraints to control the consistency of your
database. As an example, you check that the date of purchase is after 2000-01-01.
If this condition is not met, the database will refuse to insert (or modify) the record
and will return an error message.*/

ALTER TABLE main.gps_sensors
	ADD CONSTRAINT purchase_date_check 
	CHECK (purchase_date > '2000-01-01'::date);

/*Import Information on Animals and Add Constraints to the Table*/
CREATE TABLE main.animals(
	animals_id integer,
	animals_code character varying(20) NOT NULL,
	name character varying(40),
	sex character(1),
	age_class_code integer,
	species_code integer,
	note character varying,
	CONSTRAINT animals_pkey PRIMARY KEY (animals_id)
);
COMMENT ON TABLE main.animals
IS 'Animals catalog with the main information on individuals.';

/*To enforce consistency in the database, in these cases, you can use lookup tables.
Lookup tables store the list and the description of all possible values 
referenced by specific fields in different tables and constitute the definition of the valid domain.
It is recommended to keep them in a separated
schema to give the database a more readable and clear data structure. Therefore,
you create a lu_tables schema:

*/
CREATE SCHEMA lu_tables;
	GRANT USAGE ON SCHEMA lu_tables TO basic_user;
	COMMENT ON SCHEMA lu_tables
IS 'Schema that stores look up tables.';

/*You set as default that the user basic_user will be able to run SELECT queries
on all the tables that will be created in this schema:*/
ALTER DEFAULT PRIVILEGES 
	IN SCHEMA lu_tables 
	GRANT SELECT ON TABLES 
	TO basic_user;
	
/*Now, you create a lookup table for species:*/
CREATE TABLE lu_tables.lu_species(
	species_code integer,
	species_description character varying,
	CONSTRAINT lu_species_pkey PRIMARY KEY (species_code)
);
COMMENT ON TABLE lu_tables.lu_species
IS 'Look up table for species.';

INSERT INTO lu_tables.lu_species 
	VALUES (1, 'roe deer');
INSERT INTO lu_tables.lu_species 
	VALUES (2, 'rein deer');
INSERT INTO lu_tables.lu_species 
	VALUES (3, 'moose');

CREATE TABLE lu_tables.lu_age_class(
	age_class_code integer, 
	age_class_description character varying,
	CONSTRAINT lage_class_pkey PRIMARY KEY (age_class_code)
);
COMMENT ON TABLE lu_tables.lu_age_class
IS 'Look up table for age classes.';

INSERT INTO lu_tables.lu_age_class 
	VALUES (1, 'fawn');
INSERT INTO lu_tables.lu_age_class 
	VALUES (2, 'yearling');
INSERT INTO lu_tables.lu_age_class 
	VALUES (3, 'adult');

/*At this stage, you can create the foreign keys between the main.animals table
and the two lookup tables:*/
ALTER TABLE main.animals
	ADD CONSTRAINT animals_lu_species 
	FOREIGN KEY (species_code) REFERENCES lu_tables.lu_species (species_code) 
	MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE main.animals
	ADD CONSTRAINT animals_lu_age_class 
	FOREIGN KEY (age_class_code) REFERENCES lu_tables.lu_age_class (age_class_code) 
	MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
	
/*For sex class of deer, you do not expect to have more than the two possible
values: female and male (stored in the database as ‘f’ and ‘m’ to simplify data
input). In this case, instead of a lookup table you can set a check on the field:*/
ALTER TABLE main.animals
	ADD CONSTRAINT sex_check 
	CHECK (sex = 'm' OR sex = 'f');
	
ALTER TABLE main.animals 
	ADD COLUMN insert_timestamp timestamp with time zone DEFAULT now();
	
COPY main.animals(
	animals_id,animals_code, name, sex, age_class_code, species_code)
FROM
	'/var/www/RealTime/tracking_db/data/animals/animals.csv' WITH (FORMAT csv, DELIMITER ';');
	
	---or
insert into main.animals(
	animals_id, animals_code, name, sex, age_class_code, species_code)
values (1, 'F09', 'Elephant', 'f',3,1);
insert into main.animals(
	animals_id, animals_code, name, sex, age_class_code, species_code)
values (2, 'M03', 'Rhino', 'm',3,1);
insert into main.animals(
	animals_id, animals_code, name, sex, age_class_code, species_code)
values (3, 'M06', 'Hippo', 'm',3,1);
insert into main.animals(
	animals_id, animals_code, name, sex, age_class_code, species_code)
values (4, 'F10', 'Zebra', 'f',3,1);
insert into main.animals(
	animals_id, animals_code, name, sex, age_class_code, species_code)
values (5, 'M10', 'Monkey', 'm',3,1);
/*To test the result, you can retrieve the animals’ data with the extended species
and age class description:*/
SELECT
	animals.animals_id AS id, 
	animals.animals_code AS code, 
	animals.name, 
	animals.sex, 
	lu_age_class.age_class_description AS age_class, 
	lu_species.species_description AS species
FROM
	lu_tables.lu_age_class, 
	lu_tables.lu_species, 
	main.animals
WHERE
	lu_age_class.age_class_code = animals.age_class_code 
	AND
	lu_species.species_code = animals.species_code;
	
/*The result of the query is*/
 id | code |      name  | sex | age_class |species 
----+------+------------+-----+-----------+----------
 1  | F09  | Elephant   | f   | adult     |roe deer
 2  | M03  | Rhino      | m   | adult     |roe deer
 3  | M06  | Hippo      | m   | adult     |roe deer
 4  | F10  | Zebra      | f   | adult     |roe deer
 5  | M10  | Monkey     | m   | adult     |roe deer
 
 /*From Data to Information: Associating GPS Positions with Animals*/

CREATE TABLE main.gps_sensors_animals(
	gps_sensors_animals_id serial NOT NULL, 
	animals_id integer NOT NULL, 
	gps_sensors_id integer NOT NULL,
	start_time timestamp with time zone NOT NULL, 
	end_time timestamp with time zone,
	notes character varying, 
	insert_timestamp timestamp with time zone DEFAULT now(),
	CONSTRAINT gps_sensors_animals_pkey PRIMARY KEY (gps_sensors_animals_id ),
	CONSTRAINT gps_sensors_animals_animals_id_fkey FOREIGN KEY (animals_id) REFERENCES main.animals (animals_id) 
	MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
	CONSTRAINT gps_sensors_animals_gps_sensors_id_fkey FOREIGN KEY (gps_sensors_id) REFERENCES main.gps_sensors (gps_sensors_id) 
	MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
	CONSTRAINT time_interval_check CHECK (end_time > start_time)
);
COMMENT ON TABLE main.gps_sensors_animals
IS 'Table that stores information of deployments of sensors on animals.';

/*populating the table*/
COPY main.gps_sensors_animals(
	animals_id, gps_sensors_id, start_time, end_time, notes)
FROM
	'/var/www/RealTime/tracking_db/data/sensors_animals/gps_sensors_animals.csv' WITH (FORMAT csv, DELIMITER ';');
	
/*use an SQL statement to obtain the id of the animal related to each GPS position*/	
SELECT
	deployment.gps_sensors_id AS sensor, 
	deployment.animals_id AS animal,
	data.acquisition_time, 
	data.longitude::numeric(10,2) AS long, 
	data.latitude::numeric(10,2) AS lat
FROM
	main.gps_sensors_animals AS deployment,
	main.gps_data AS data,
	main.gps_sensors AS gps
WHERE
	data.gps_sensors_code = gps.gps_sensors_code AND
	gps.gps_sensors_id = deployment.gps_sensors_id AND
	(
		(
		data.acquisition_time >= deployment.start_time AND 
		data.acquisition_time <= deployment.end_time and
		--is not null
		data.longitude !=0 and
		data.latitude !=0 
		)
		OR 
		(
		data.acquisition_time >= deployment.start_time AND 
		deployment.end_time IS NULL and 
		--is not null
		data.longitude !=0 and
		data.latitude !=0 
		)
	)
ORDER BY 
	animals_id, acquisition_time
LIMIT 10;
/*use an SQL statement to obtain the id of the animal related to each GPS position*/
SELECT
	deployment.gps_sensors_id AS sensor, 
	deployment.animals_id AS animal,
	data.acquisition_time::date as date,
	data.acquisition_time::time as time, 
	data.longitude::numeric(10,5) AS long, 
	data.latitude::numeric(10,5) AS lat
FROM
	main.gps_sensors_animals AS deployment,
	main.gps_data AS data,
	main.gps_sensors AS gps
WHERE
data.gps_sensors_code = gps.gps_sensors_code and
gps.gps_sensors_id = deployment.gps_sensors_id and
( (
data.acquisition_time >= deployment.start_time and
data.acquisition_time <= deployment.end_time and
--is not null
data.longitude !=0 and
data.latitude !=0
)or(
data.acquisition_time >= deployment.start_time and
deployment.end_time is null and
--is not null
data.longitude !=0 and
data.latitude !=0
))
order by 
animals_id, acquisition_time
limit 50;
 
/*the results is*/
 sensor | animal |    acquisition_time    |   long   | lat 
--------+--------+------------------------+----------+----------
   4    |  1     | 2005-10-18 20:00:54+00 | 11.04413 |46.01096
   4    |  1     | 2005-10-19 00:01:23+00 | 11.04454 |46.01178
   4    |  1     | 2005-10-19 04:02:22+00 | 11.04515 |46.00793
   4    |  1     | 2005-10-19 08:03:08+00 | 11.04567 |46.00600
   4    |  1     | 2005-10-20 20:00:53+00 | 11.04286 |46.01015
   4    |  1     | 2005-10-21 00:00:48+00 | 11.04172 |46.01051
   4    |  1     | 2005-10-21 04:00:53+00 | 11.04089 |46.01028
   4    |  1     | 2005-10-21 08:01:42+00 | 11.04429 |46.00669
   4    |  1     | 2005-10-21 12:03:11+00 | 11.02020 |46.23838
   4    |  1     | 2005-10-21 16:01:16+00 | 11.04622 |46.00684
   
/*Below is the SQL code that generates main.gps_data_animals table:*/
   
CREATE TABLE main.gps_data_animals(
	gps_data_animals_id serial NOT NULL, 
	gps_sensors_id integer, 
	animals_id integer,
	acquisition_time timestamp with time zone, 
	longitude double precision,
	latitude double precision,
	insert_timestamp timestamp with time zone DEFAULT now(), 
	CONSTRAINT gps_data_animals_pkey PRIMARY KEY (gps_data_animals_id),
	CONSTRAINT gps_data_animals_animals_fkey FOREIGN KEY (animals_id) REFERENCES main.animals (animals_id) 
	MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT gps_data_animals_gps_sensors FOREIGN KEY (gps_sensors_id) REFERENCES main.gps_sensors (gps_sensors_id) 
	MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
COMMENT ON TABLE main.gps_data_animals 
IS 'GPS sensors data associated with animals wearing the sensor.';
/* */
CREATE INDEX gps_data_animals_acquisition_time_index
	ON main.gps_data_animals
	USING BTREE (acquisition_time);
/* */
CREATE INDEX gps_data_animals_animals_id_index
	ON main.gps_data_animals
	USING BTREE (animals_id);
	
/*At this point, you can feed this new table with the data in the table gps_data and use gps_sensors_animals to derive the id of the animals*/

INSERT INTO main.gps_data_animals (
	animals_id, gps_sensors_id, acquisition_time, longitude, latitude) 
SELECT
	gps_sensors_animals.animals_id,
	gps_sensors_animals.gps_sensors_id,
	gps_data.acquisition_time, 
	gps_data.longitude,
	gps_data.latitude
FROM
	main.gps_sensors_animals, 
	main.gps_data, 
	main.gps_sensors
WHERE
	gps_data.gps_sensors_code = gps_sensors.gps_sensors_code AND
	gps_sensors.gps_sensors_id = gps_sensors_animals.gps_sensors_id AND
	(
		--is not null
		gps_data.longitude !=0 and
		gps_data.latitude !=0 and
		(
		gps_data.acquisition_time>=gps_sensors_animals.start_time AND 
		gps_data.acquisition_time<=gps_sensors_animals.end_time
		
		)
		OR 
		(
		gps_data.acquisition_time>=gps_sensors_animals.start_time AND 
		gps_sensors_animals.end_time IS NULL
		
		)
	);
	
	
/*Timestamping Changes in the Database Using Triggers*/

CREATE SCHEMA tools
	AUTHORIZATION postgres;
	GRANT USAGE ON SCHEMA tools TO basic_user;
COMMENT ON SCHEMA tools 
IS 'Schema that hosts all the functions and ancillary tools used for the 
database.';

ALTER DEFAULT PRIVILEGES 
	IN SCHEMA tools 
	GRANT SELECT ON TABLES 
	TO basic_user;
	
/*PostgreSQL functions and triggers*/
CREATE FUNCTION tools.test_add(integer, integer) 
	RETURNS integer AS 'SELECT $1 + $2;'
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;

/*example of a trigger, you add a field to the table
gps_data_animals where you register the timestamp of the last modification
(update) of each record in order to keep track of the changes in the table*/

ALTER TABLE main.gps_data_animals 
	ADD COLUMN update_timestamp timestamp with time zone DEFAULT now();

/*a function called by a trigger to
update this field whenever a record is updated. The SQL to generate the function is*/
CREATE OR REPLACE FUNCTION tools.timestamp_last_update()
RETURNS trigger AS
$BODY$
BEGIN
IF NEW IS DISTINCT FROM OLD THEN
	NEW.update_timestamp = now();
END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
COMMENT ON FUNCTION tools.timestamp_last_update() 
IS 'When a record is updated, the update_timestamp is set to the current 
time.';

/*Here is the code for the trigger that calls the function:*/
CREATE TRIGGER update_timestamp
	BEFORE UPDATE
	ON main.gps_data_animals
	FOR EACH ROW
	EXECUTE PROCEDURE tools.timestamp_last_update();
	
/*You have to initialise the existing records in the table, as the trigger/function
was not yet created when data were uploaded:*/

UPDATE main.gps_data_animals 
	SET update_timestamp = now();
	
/*You can now repeat the same operation for the other tables in the database:*/
ALTER TABLE main.gps_sensors 
	ADD COLUMN update_timestamp timestamp with time zone DEFAULT now();
	
ALTER TABLE main.animals 
	ADD COLUMN update_timestamp timestamp with time zone DEFAULT now();
	
ALTER TABLE main.gps_sensors_animals 
	ADD COLUMN update_timestamp timestamp with time zone DEFAULT now();
	
CREATE TRIGGER update_timestamp
	BEFORE UPDATE
	ON main.gps_sensors
	FOR EACH ROW
	EXECUTE PROCEDURE tools.timestamp_last_update();
CREATE TRIGGER update_timestamp
	BEFORE UPDATE
	ON main.gps_sensors_animals
	FOR EACH ROW
	EXECUTE PROCEDURE tools.timestamp_last_update();
CREATE TRIGGER update_timestamp
	BEFORE UPDATE
	ON main.animals
	FOR EACH ROW
	EXECUTE PROCEDURE tools.timestamp_last_update();
	
UPDATE main.gps_sensors 
	SET update_timestamp = now();
UPDATE main.gps_sensors_animals 
	SET update_timestamp = now();
UPDATE main.animals 
	SET update_timestamp = now();
---###################################################################----738	
/*Another interesting application of triggers is the automation of the
acquisition_time computation when a new record is inserted into the gps_data table:*/
CREATE OR REPLACE FUNCTION tools.acquisition_time_update()
RETURNS trigger AS
$BODY$BEGIN
	NEW.acquisition_time = ((NEW.utc_date + NEW.utc_time) at time zone 'UTC');
	RETURN NEW;
END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
COMMENT ON FUNCTION tools.acquisition_time_update() 
IS 'When a record is inserted, the acquisition_time is composed from 
utc_date and utc_time.';

CREATE TRIGGER update_acquisition_time
	BEFORE INSERT
	ON main.gps_data
	FOR EACH ROW
	EXECUTE PROCEDURE tools.acquisition_time_update();
	
/*Automation of the GPS Data Association with Animals*/
CREATE OR REPLACE FUNCTION tools.gps_data2gps_data_animals()
RETURNS trigger AS
$BODY$ begin
INSERT INTO main.gps_data_animals (
	animals_id, gps_sensors_id, acquisition_time, longitude, latitude)
SELECT
	gps_sensors_animals.animals_id, gps_sensors_animals.gps_sensors_id, 
	NEW.acquisition_time, NEW.longitude, NEW.latitude
FROM
	main.gps_sensors_animals, main.gps_sensors
WHERE
	NEW.gps_sensors_code = gps_sensors.gps_sensors_code AND 
	gps_sensors.gps_sensors_id = gps_sensors_animals.gps_sensors_id AND
	( 
		(NEW.acquisition_time >= gps_sensors_animals.start_time AND 
		NEW.acquisition_time <= gps_sensors_animals.end_time)
		OR 
		(NEW.acquisition_time >= gps_sensors_animals.start_time AND 
		gps_sensors_animals.end_time IS NULL)
	);
RETURN NULL;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
COMMENT ON FUNCTION tools.gps_data2gps_data_animals() 
IS 'Automatic upload data from gps_data to gps_data_animals.';

/*Then, you create a trigger that calls the function whenever a new record is
uploaded into gps_data:*/
CREATE TRIGGER trigger_gps_data_upload
	AFTER INSERT
	ON main.gps_data
	FOR EACH ROW
	EXECUTE PROCEDURE tools.gps_data2gps_data_animals();
COMMENT ON TRIGGER trigger_gps_data_upload ON main.gps_data
IS 'Upload data from gps_data to gps_data_animals whenever a new record is 
inserted.';

---whenever a new
--GPS position is uploaded in the table main.gps_data_animals, the spatial geometry
--is also created.
CREATE OR REPLACE FUNCTION tools.new_gps_data_animals()
RETURNS trigger AS
$BODY$
DECLARE
thegeom geometry;
BEGIN
IF NEW.longitude IS NOT NULL AND NEW.latitude IS NOT NULL THEN
thegeom = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude),4326);
NEW.geom = thegeom;
END IF;
RETURN NEW;
END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
COMMENT ON FUNCTION tools.new_gps_data_animals()
IS 'When called by a trigger (insert_gps_locations) this function populates
the field geom using the values from longitude and latitude fields.';
---respective trigger
CREATE TRIGGER insert_gps_location
BEFORE INSERT
ON main.gps_data_animals
FOR EACH ROW
EXECUTE PROCEDURE tools.new_gps_data_animals();
/*You can test this function by adding the last GPS sensor not yet imported:*/
COPY main.gps_data(
	gps_sensors_code, line_no, utc_date, utc_time, lmt_date, lmt_time, ecef_x, 
	ecef_y, ecef_z, latitude, longitude, height, dop, nav, validated, sats_used,
	ch01_sat_id, ch01_sat_cnr, ch02_sat_id, ch02_sat_cnr, ch03_sat_id, 
	ch03_sat_cnr, ch04_sat_id, ch04_sat_cnr, ch05_sat_id, ch05_sat_cnr, 
	ch06_sat_id, ch06_sat_cnr, ch07_sat_id, ch07_sat_cnr, ch08_sat_id, 
	ch08_sat_cnr, ch09_sat_id, ch09_sat_cnr, ch10_sat_id, ch10_sat_cnr, 
	ch11_sat_id, ch11_sat_cnr, ch12_sat_id, ch12_sat_cnr, main_vol, bu_vol, 
	temp, easting, northing, remarks)
FROM
	'/var/www/RealTime/tracking_db/data/sensors_data/GSM02927.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	
/*Data are automatically processed and imported into the table gps_data_animals
including the correct association with the animal wearing the sensor*/
insert into main.gps_data(
	gps_sensors_code, line_no, utc_date, utc_time, lmt_date, lmt_time, ecef_x, 
	ecef_y, ecef_z, latitude, longitude, height, dop, nav, validated, sats_used,
	ch01_sat_id, ch01_sat_cnr, ch02_sat_id, ch02_sat_cnr, ch03_sat_id, 
	ch03_sat_cnr, ch04_sat_id, ch04_sat_cnr, ch05_sat_id, ch05_sat_cnr, 
	ch06_sat_id, ch06_sat_cnr, ch07_sat_id, ch07_sat_cnr, ch08_sat_id, 
	ch08_sat_cnr, ch09_sat_id, ch09_sat_cnr, ch10_sat_id, ch10_sat_cnr, 
	ch11_sat_id, ch11_sat_cnr, ch12_sat_id, ch12_sat_cnr, main_vol, bu_vol, 
	temp, easting, northing, remarks)
values ('GSM02927',2957,'2015-04-03','06:02:16','2015-04-03','06:02:16',
4351279,850828,4570836,46.0649332,11.0637448,802.28,3.8,'3D','Yes',
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3.44,3.52,6,1659642,5103347,'hey');

---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@---816

/*Consistency Checks on the Deployments Information
Here is an example of code for this function:*/

CREATE OR REPLACE FUNCTION tools.gps_sensors_animals_consistency_check()
RETURNS trigger AS
$BODY$
DECLARE
	deletex integer;
BEGIN
SELECT
	gps_sensors_animals_id 
INTO
	deletex 
FROM
	main.gps_sensors_animals b
WHERE
	(NEW.animals_id = b.animals_id OR NEW.gps_sensors_id = b.gps_sensors_id)
	AND
	(
	(NEW.start_time > b.start_time AND NEW.start_time < b.end_time)
	OR
	(NEW.start_time > b.start_time AND b.end_time IS NULL)
	OR
	(NEW.end_time > b.start_time AND NEW.end_time < b.end_time)
	OR
	(NEW.start_time < b.start_time AND NEW.end_time > b.end_time)
	OR
	(NEW.start_time < b.start_time AND NEW.end_time IS NULL )
	OR
	(NEW.end_time > b.start_time AND b.end_time IS NULL)
);
IF deletex IS not NULL THEN
	IF TG_OP = 'INSERT' THEN
		RAISE EXCEPTION 'This row is not inserted: Animal-sensor association not 
		valid: (the same animal would wear two different GPS sensors at the same 
		time or the same GPS sensor would be deployed on two animals at the same 
		time).';
		RETURN NULL;
	END IF;
	IF TG_OP = 'UPDATE' THEN
		IF deletex != OLD.gps_sensors_animals_id THEN
			RAISE EXCEPTION 'This row is not updated: Animal-sensor association 
			not valid (the same animal would wear two different GPS sensors at the same 
			time or the same GPS sensor would be deployed on two animals at the same 
			time).';
			RETURN NULL;
		END IF;
	END IF;
END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
COMMENT ON FUNCTION tools.gps_sensors_animals_consistency_check() 
IS 'Check if a modified or insert row in gps_sensors_animals is valid (no 
impossible time range overlaps of deployments).';

/*Here is an example of the trigger to call the function:*/
CREATE TRIGGER gps_sensors_animals_changes_consistency
	BEFORE INSERT OR UPDATE
	ON main.gps_sensors_animals
	FOR EACH ROW
	EXECUTE PROCEDURE tools.gps_sensors_animals_consistency_check();
	
/*You can test this process by trying to insert a deployment of a GPS sensor in the
gps_sensors_animalstable in a time interval that overlaps the association of the
same sensor on another animal:*/
INSERT INTO main.gps_sensors_animals
	(animals_id, gps_sensors_id, start_time, end_time, notes)
VALUES
	(2,2,'2004-10-23 20:00:53 +0','2005-11-28 13:00:00 +0','Ovelapping 
	sensor');


	/*
	
You should receive an error message like:
	********** Error **********
ERROR: This row is not inserted: Animal-sensor association not valid: (the same
animal would wear two different GPS sensors at the same time or the same GPS
sensor would be deployed on two animals at the same time).
SQL state: P0001*/

/*Synchronisation of gps_sensors_animals and gps_data_animals*/
CREATE OR REPLACE FUNCTION tools.gps_sensors_animals2gps_data_animals()
RETURNS trigger AS
$BODY$ BEGIN

IF TG_OP = 'DELETE' THEN
	DELETE FROM 
		main.gps_data_animals 
	WHERE 
		animals_id = OLD.animals_id AND
		gps_sensors_id = OLD.gps_sensors_id AND
		acquisition_time >= OLD.start_time AND
		(acquisition_time <= OLD.end_time OR OLD.end_time IS NULL);
	RETURN NULL;
END IF;

IF TG_OP = 'INSERT' THEN
	INSERT INTO 
		main.gps_data_animals (gps_sensors_id, animals_id, acquisition_time, 
		longitude, latitude)
	SELECT 
		NEW.gps_sensors_id, NEW.animals_id, gps_data.acquisition_time, 
		gps_data.longitude, gps_data.latitude
	FROM 
		main.gps_data, main.gps_sensors
	WHERE 
		NEW.gps_sensors_id = gps_sensors.gps_sensors_id AND
		gps_data.gps_sensors_code = gps_sensors.gps_sensors_code AND
		gps_data.acquisition_time >= NEW.start_time AND
		(gps_data.acquisition_time <= NEW.end_time OR NEW.end_time IS NULL);
	RETURN NULL;
END IF;

IF TG_OP = 'UPDATE' THEN
	DELETE FROM 
		main.gps_data_animals 
	WHERE
		gps_data_animals_id IN (
			SELECT 
				d.gps_data_animals_id 
			FROM
				gps_data_animals_id, gps_sensors_id, animals_id, acquisition_time 
			FROM 
				main.gps_data_animals
			WHERE 
				gps_sensors_id = OLD.gps_sensors_id AND
				animals_id = OLD.animals_id AND
				acquisition_time >= OLD.start_time AND
				(acquisition_time <= OLD.end_time OR OLD.end_time IS NULL)
			) d
			LEFT OUTER JOIN
				(SELECT 
				gps_data_animals_id, gps_sensors_id, animals_id, acquisition_time 
				FROM 
				main.gps_data_animals
				WHERE 
				gps_sensors_id = NEW.gps_sensors_id AND
				animals_id = NEW.animals_id AND
				acquisition_time >= NEW.start_time AND
				(acquisition_time <= NEW.end_time OR NEW.end_time IS NULL) 
			) e
		ON 
			(d.gps_data_animals_id = e.gps_data_animals_id)
		WHERE e.gps_data_animals_id IS NULL);
	INSERT INTO 
		main.gps_data_animals (gps_sensors_id, animals_id, acquisition_time, 
		longitude, latitude) 
	SELECT 
		u.gps_sensors_id, u.animals_id, u.acquisition_time, u.longitude, 
		u.latitude
	FROM
		(SELECT 
			NEW.gps_sensors_id AS gps_sensors_id, NEW.animals_id AS animals_id, 
			gps_data.acquisition_time AS acquisition_time, gps_data.longitude AS 
			longitude, gps_data.latitude AS latitude
		FROM 
			main.gps_data, main.gps_sensors
		WHERE 
			NEW.gps_sensors_id = gps_sensors.gps_sensors_id AND 
			gps_data.gps_sensors_code = gps_sensors.gps_sensors_code AND
			gps_data.acquisition_time >= NEW.start_time AND
			(acquisition_time <= NEW.end_time OR NEW.end_time IS NULL)
		) u
	LEFT OUTER JOIN
		(SELECT 
			gps_data_animals_id, gps_sensors_id, animals_id, acquisition_time 
		FROM 
			main.gps_data_animals
		WHERE 
			gps_sensors_id = OLD.gps_sensors_id AND
			animals_id = OLD.animals_id AND
			acquisition_time >= OLD.start_time AND
			(acquisition_time <= OLD.end_time OR OLD.end_time IS NULL)
		) w
	ON 
		(u.gps_sensors_id = w.gps_sensors_id AND 
		u.animals_id = w.animals_id AND 
		u.acquisition_time = w.acquisition_time )
	WHERE 
		w.gps_data_animals_id IS NULL;
	RETURN NULL;
END IF;

END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
COMMENT ON FUNCTION tools.gps_sensors_animals2gps_data_animals() 
IS 'When a record in gps_sensors_animals is deleted OR updated OR inserted, 
this function synchronizes this information with gps_data_animals.';

/*Here is the code of the trigger to call the function:*/
CREATE TRIGGER synchronize_gps_data_animals
	AFTER INSERT OR UPDATE OR DELETE
	ON main.gps_sensors_animals
	FOR EACH ROW
	EXECUTE PROCEDURE tools.gps_sensors_animals2gps_data_animals();
		
	
---#################################################################################
	
copy main.parcels (
parcel_id, f_r, area_ha, area_ac, dp_no, lr_no, auth_date, land_owners, pin, parcel_no, geom
)
from '/tmp/parcels.csv'
with (format csv, header, delimiter ';')
	
---
---function
CREATE OR REPLACE FUNCTION tools.srid_utm(longitude double precision,latitude
double precision)
RETURNS integer AS
$BODY$
DECLARE
srid integer;
lon float;
lat float;
BEGIN
lat := latitude;
lon := longitude;
IF ((lon > 360 or lon < -360) or (lat > 90 or lat < -90)) THEN
RAISE EXCEPTION 'Longitude and latitude is not in a valid format (-360 to
360; -90 to 90)';
ELSEIF (longitude < -180)THEN
lon := 360 + lon;
ELSEIF (longitude > 180)THEN
lon := 180 - lon;
END IF;
IF latitude >= 0 THEN
srid := 32600 + floor((lon+186)/6);
ELSE
srid := 32700 + floor((lon+186)/6);
END IF;
RETURN srid;
END;
$BODY$
LANGUAGE plpgsql VOLATILE STRICT
COST 100;
COMMENT ON FUNCTION tools.srid_utm(double precision, double precision)
IS 'Function that returns the SRID code of the UTM zone where a point (in
geographic coordinates) is located. For polygons or line, it can be used
giving ST_x(ST_Centroid(the_geom)) and ST_y(ST_Centroid(the_geom)) as
parameters. This function is typically used be used with ST_Transform to
project elements with no prior knowledge of their position.';
---function call
select tools.srid_utm(36.821, -1.2145) as UTM_Zone;

----projecting points using above fxn
SELECT
ST_AsEWKT(
ST_Transform(
ST_SetSRID(ST_MakePoint(36.821, -1.2145), 4326),
TOOLS.SRID_UTM(36.821, -1.2145))
) AS projected_point;
---when you
---have a number of locations per animal, you can find the centroid of the area
---covered by the locations:
SELECT
animals_id,
ST_AsEWKT(
ST_Centroid(
ST_Collect(geom))) AS centroid
FROM
main.gps_data_animals
WHERE
geom IS NOT NULL
GROUP BY
animals_id
ORDER BY
animals_id;

----##Views
CREATE SCHEMA analysis
AUTHORIZATION postgres;
GRANT USAGE ON SCHEMA analysis TO basic_user;
COMMENT ON SCHEMA analysis
IS 'Schema that stores key layers for analysis.';

CREATE VIEW analysis.view_gps_locations AS
SELECT
gps_data_animals.gps_data_animals_id,
gps_data_animals.animals_id,
animals.name,
gps_data_animals.acquisition_time at time zone 'UTC' AS time_utc,
animals.sex,
lu_age_class.age_class_description,
lu_species.species_description,
gps_data_animals.geom
FROM
main.gps_data_animals,
main.animals,
lu_tables.lu_age_class,
lu_tables.lu_species
WHERE
gps_data_animals.animals_id = animals.animals_id AND
animals.age_class_code = lu_age_class.age_class_code AND
animals.species_code = lu_species.species_code AND
geom IS NOT NULL;
COMMENT ON VIEW analysis.view_gps_locations
IS 'GPS locations.';

---viewing views
SELECT
gps_data_animals_id AS id,
name AS animal,
time_utc,
sex,
age_class_description AS age,
species_description AS species
FROM
analysis.view_gps_locations
LIMIT 10;

----convex hull view
CREATE VIEW analysis.view_trajectories AS
SELECT
animals_id,
ST_MakeLine(geom)::geometry(LineString,4326) AS geom
FROM
(SELECT animals_id, geom, acquisition_time
FROM main.gps_data_animals
WHERE geom IS NOT NULL
ORDER BY
animals_id, acquisition_time) AS sel_subquery
GROUP BY
animals_id;
COMMENT ON VIEW analysis.view_trajectories
IS 'GPS locations - Trajectories.';

---convex hull view
CREATE VIEW analysis.view_convex_hulls AS
SELECT
animals_id,
(ST_ConvexHull(ST_Collect(geom)))::geometry(Polygon,4326) AS geom
FROM
main.gps_data_animals
WHERE
geom IS NOT NULL
GROUP BY
animals_id
ORDER BY
animals_id;
COMMENT ON VIEW analysis.view_convex_hulls
IS 'GPS locations - Minimum convex polygons.';

---new schema
CREATE SCHEMA env_data
AUTHORIZATION postgres;
GRANT USAGE ON SCHEMA env_data TO basic_user;
COMMENT ON SCHEMA env_data
IS 'Schema that stores environmental ancillary information.';
ALTER DEFAULT PRIVILEGES IN SCHEMA env_data
GRANT SELECT ON TABLES TO basic_user;

----Importing Vector Files
---loading data
"C:\Program Files\PostgreSQL\9.2\bin\shp2pgsql.exe" -s 4326 -I
C:\tracking_db\data\env_data\vector\meteo_stations.shp
env_data.meteo_stations | "C:\Program Files\PostgreSQL\9.2\bin\psql.exe" -p
5432 -d gps_tracking_db -U postgres -h localhost


"C:\Program Files\PostgreSQL\9.2\bin\shp2pgsql.exe" -s 4326 -I
C:\tracking_db\data\env_data\vector\roads.shp env_data.roads | "C:\Program
Files\PostgreSQL\9.2\bin\psql.exe" -p 5432 -d gps_tracking_db -U postgres -h
localhost


----Importing Raster Files
"C:\Program Files\PostgreSQL\9.2\bin\raster2pgsql.exe" -I -M -C -s 4326 -t
20x20 C:\tracking_db\data\env_data\raster\srtm_dem.tif env_data.srtm_dem |
"C:\Program Files\PostgreSQL\9.2\bin\psql.exe" -p 5432 -d gps_tracking_db -U
postgres -h localhost

"C:\Program Files\PostgreSQL\9.2\bin\raster2pgsql.exe" -I -M -C -s 3035
-t 20x20 C:\tracking_db\data\env_data\raster\corine06.tif
env_data.corine_land_cover | "C:\Program Files\PostgreSQL\9.2\bin\psql.exe"
-p 5432 -d gps_tracking_db -U postgres -h localhost

---retrieve information
SELECT * FROM geometry_columns;

---create table
CREATE TABLE env_data.corine_land_cover_legend(
grid_code integer NOT NULL,
clc_l3_code character(3),
label1 character varying,
label2 character varying,
label3 character varying,
CONSTRAINT corine_land_cover_legend_pkey
PRIMARY KEY (grid_code ));
COMMENT ON TABLE env_data.corine_land_cover_legend
IS 'Legend of Corine land cover, associating the numeric code to the three
nested levels.';

-----load data
COPY env_data.corine_land_cover_legend
FROM
'C:\tracking_db\data\env_data\raster\corine_legend.csv'
WITH (FORMAT csv, HEADER, DELIMITER ';');

---retrieve information
SELECT * FROM raster_columns;


---documenting database
COMMENT ON TABLE env_data.adm_boundaries
IS 'Layer (polygons) of administrative boundaries (comuni).';
COMMENT ON TABLE env_data.corine_land_cover
IS 'Layer (raster) of land cover (from Corine project).';
COMMENT ON TABLE env_data.meteo_stations
IS 'Layer (points) of meteo stations.';
COMMENT ON TABLE env_data.roads
IS 'Layer (lines) of roads network.';
COMMENT ON TABLE env_data.srtm_dem
IS 'Layer (raster) of digital elevation model (from SRTM project).';
COMMENT ON TABLE env_data.study_area
IS 'Layer (polygons) of the boundaries of the study area.';

---Querying
--intersection of spatial elements:
SELECT
nome_com
FROM
env_data.adm_boundaries
WHERE
ST_Intersects((ST_SetSRID(ST_MakePoint(11,46), 4326)), geom);

---compute the distance (rounded to the metre) from the
--point at coordinates (11, 46) to all the meteorological stations (ordered by distance)
--in the table env_data.meteo_stations.
SELECT
station_id, ST_Distance_Spheroid((ST_SetSRID(ST_MakePoint(11,46), 4326)),
geom, 'SPHEROID["WGS 84",6378137,298.257223563]')::integer AS distance
FROM
env_data.meteo_stations
ORDER BY
distance;
---compute the distance to the closest road
SELECT
ST_Distance((ST_SetSRID(ST_MakePoint(11,46), 4326))::geography,
geom::geography)::integer AS distance
FROM
env_data.roads
ORDER BY
distance
LIMIT 1;

--- integration of both spatial and non-spatial elements in the same query
SELECT
ST_Value(srtm_dem.rast,
(ST_SetSRID(ST_MakePoint(11,46), 4326))) AS altitude,
ST_value(corine_land_cover.rast,
ST_transform((ST_SetSRID(ST_MakePoint(11,46), 4326)), 3035)) AS land_cover,
label2,label3
FROM
env_data.corine_land_cover,
env_data.srtm_dem,
env_data.corine_land_cover_legend
WHERE
ST_Intersects(corine_land_cover.rast,
ST_Transform((ST_SetSRID(ST_MakePoint(11,46), 4326)), 3035)) AND
ST_Intersects(srtm_dem.rast,(ST_SetSRID(ST_MakePoint(11,46), 4326))) AND
grid_code = ST_Value(corine_land_cover.rast,
ST_Transform((ST_SetSRID(ST_MakePoint(11,46), 4326)), 3035));

--altitude | land_cover | label2 | label3
--------------------------------------------------
--956 | 24 | Forests | Coniferous forest

--combine roads and administrative boundaries to compute how many
--metres of roads there are in each administrative unit. 
SELECT
nome_com,
sum(ST_Length(
(ST_Intersection(roads.geom, adm_boundaries.geom))::geography))::integer
AS total_length
FROM
env_data.roads,
env_data.adm_boundaries
WHERE
ST_Intersects(roads.geom, adm_boundaries.geom)
GROUP BY
nome_com
ORDER BY
total_length desc;

--nome_com | total_length
-----------------------------
--Trento | 24552
--Lasino | 15298
--Garniga Terme | 12653

---compute some statistics (minimum, maximum, mean and standard
--deviation) for the altitude within the study area
SELECT
(sum(ST_Area(((gv).geom)::geography)))/1000000 area,
min((gv).val) alt_min,
max((gv).val) alt_max,
avg((gv).val) alt_avg,
stddev((gv).val) alt_stddev
FROM
(SELECT
ST_intersection(rast, geom) AS gv
FROM
env_data.srtm_dem,
env_data.study_area
WHERE
ST_intersects(rast, geom)
) foo;

--area | alt_min | alt_max | alt_avg | alt_stddev
------------------+---------+---------+------------------+-----------------
--199.018552456188 | 180 | 2133 | 879.286157704969 | 422.56622698974

--- number of pixels of each land cover type within
--the study area
SELECT (pvc).value, SUM((pvc).count) AS total, label3
FROM
(SELECT ST_ValueCount(rast) AS pvc
FROM env_data.corine_land_cover, env_data.study_area
WHERE ST_Intersects(rast, ST_Transform(geom, 3035))) AS cnts,
env_data.corine_land_cover_legend
WHERE grid_code = (pvc).value
GROUP BY (pvc).value, label3
ORDER BY (pvc).value;

--lc_class | total | label3
----------+-------+------------------------------------------------
--1 | 114 | Continuous urban fabric
--2 | 817 | Discontinuous urban fabric
--3 | 324 | Industrial or commercial units
--7 | 125 | Mineral extraction sites


SELECT
(pvc).value,
(SUM((pvc).count)*100/ SUM(SUM((pvc).count)) over ())::numeric(4,2)
FROM
(SELECT ST_ValueCount(rast) AS pvc
FROM env_data.corine_land_cover, env_data.study_area
WHERE ST_Intersects(rast, ST_Transform(geom, 3035))) AS cnts,
env_data.corine_land_cover_legend
WHERE grid_code = (pvc).value
GROUP BY (pvc).value, label3
ORDER BY (pvc).value;

---Associate Environmental Characteristics
---with GPS Locations
ALTER TABLE main.gps_data_animals
ADD COLUMN pro_com integer;
ALTER TABLE main.gps_data_animals
ADD COLUMN corine_land_cover_code integer;
ALTER TABLE main.gps_data_animals
ADD COLUMN altitude_srtm integer;
ALTER TABLE main.gps_data_animals
ADD COLUMN station_id integer;
ALTER TABLE main.gps_data_animals
ADD COLUMN roads_dist integer;

CREATE OR REPLACE FUNCTION tools.new_gps_data_animals()
RETURNS trigger AS
$BODY$
DECLARE
thegeom geometry;
BEGIN
IF NEW.longitude IS NOT NULL AND NEW.latitude IS NOT NULL THEN
thegeom = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
NEW.geom =thegeom;
NEW.pro_com =
(SELECT pro_com::integer
FROM env_data.adm_boundaries
WHERE ST_Intersects(geom,thegeom));
NEW.corine_land_cover_code =
(SELECT ST_Value(rast,ST_Transform(thegeom,3035))
FROM env_data.corine_land_cover
WHERE ST_Intersects(ST_Transform(thegeom,3035), rast));
NEW.altitude_srtm =
(SELECT ST_Value(rast,thegeom)
FROM env_data.srtm_dem
WHERE ST_Intersects(thegeom, rast));
NEW.station_id =
(SELECT station_id::integer
FROM env_data.meteo_stations
ORDER BY ST_Distance_Spheroid(thegeom, geom, 'SPHEROID["WGS 84",
6378137,298.257223563]')
LIMIT 1);
NEW.roads_dist =
(SELECT ST_Distance(thegeom::geography, geom::geography)::integer
FROM env_data.roads
ORDER BY ST_distance(thegeom::geography, geom::geography)
LIMIT 1);
END IF;
RETURN NEW;
END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
COMMENT ON FUNCTION tools.new_gps_data_animals()
IS 'When called by the trigger insert_gps_positions (raised whenever a new
position is uploaded into gps_data_animals) this function gets the longitude
and latitude values and sets the geometry field accordingly, computing a set
of derived environmental information calculated intersecting or relating the
position with the environmental ancillary layers.';


----#########
--Chapter 10
----$$$$$$$$$

create table main.parcels(
parcel_id serial,
f_r character varying(25),
area_ha double precision,
area_ac double precision,
dp_no character varying(25),
lr_no character varying(25),
auth_date date,
land_owners character varying(50),
pin character varying(25),
parcel_no character varying(50),
geom geometry(MultiPolygon, 21037),
CONSTRAINT parcel_id_pkey PRIMARY KEY(parcel_id)
);
comment on table main.parcels is 'Table for storing land information and aucillary information about the owners';	
	
create table public.users(
user_id serial,
email varchar(100) not null,
first_name varchar(50) not null,
last_name varchar(50) not null,
idnumber integer not null,
pass char(40) not null,
phone integer not null,
registration_date timestamp with time zone,
active char(32) not null,
constraint users_pkey primary key (user_id),
constraint users_uque unique (email)
);
comment on table  public.users is 'Table for users of enterprises';

CREATE TABLE public.sales(
sales_id serial,
fname varchar(50) NOT NULL,
email varchar(100) NOT NULL,
phone varchar(10),
lat double precision,
lng double precision,
token varchar(50) NOT NULL,
CONSTRAINT sales_id_pkey PRIMARY KEY(sales_id),
CONSTRAINT email_unique UNIQUE (email)
);
COMMENT ON TABLE public.sales is 'Table for sale';
  

--
-- Dumping data for table `users`
--

INSERT INTO users (user_id, email, pass, first_name, last_name, idnumber, phone, active, registration_date) VALUES
(12, 'jm@gmail.com', crypt('root', gen_salt('md5')), 'josh', 'hush', 27812564, 721384299, '8698ca22e2ff80b61a60b694d277ce8e', null),
(13, 'epuret@gmail.com', crypt('root', gen_salt('md5')), 'james', 'epuret', 37282891, 2147483647, 'c00b2c9537e030541542f5e3935a7ccf', null),
(14, 'joshuairungu12@gmail.com', crypt('root', gen_salt('md5')), 'joshua', 'irungu', 27042053, 721659177, '0d010fb625297ca3b7310ada0852c63e', null),
(15, 'hj@gmail.com', crypt('root', gen_salt('md5')), 'fgh', 'ggk', 4758, 42882, 'c4ca6d34c772102fcd01a60b4147d442', null);

---Trigger
CREATE TRIGGER update_token
	AFTER INSERT
	ON public.sales
	FOR EACH ROW
	EXECUTE PROCEDURE tools.sales2parcels();
	
---Function
CREATE OR REPLACE FUNCTION tools.sales2parcels()
RETURNS TRIGGER AS
$BODY$BEGIN
	UPDATE public.parcels SET parcels.token = (
		SELECT s.token FROM parcels p , sales s
		WHERE ST_CONTAINS(p.geom, s.geom));
END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
COMMENT ON FUNCTION tools.acquisition_time_update() 
IS 'Populates the token field in parcels table';

	

