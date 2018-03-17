---Database
create database fire;
comment on database fire is 'Real time vehicle positions';

---Schema public
---Tables
CREATE TABLE public.gps_data(
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
	remarks character varying,
	insert_timestamp timestamp with time zone default now(),
	constraint gps_data_pkey primary key(gps_data_id),
	constraint unique_gps_data_record unique(gps_sensors_code, line_no),
	CONSTRAINT gps_data_gps_sensors_fkey FOREIGN KEY (gps_sensors_code) REFERENCES public.gps_sensors (gps_sensors_code) 
	MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
COMMENT ON TABLE public.gps_data
IS 'Table that stores raw data as they come from the sensors (plus the ID of
the sensor).';

create table public.vehicles(
vehicles_id serial,
vehicles_code varchar(20),
gps_sensors_id character varying,
model_name character varying,
capacity integer,
driver_id character varying,
contacts integer,
status character varying,
insert_timestamp timestamp with time zone default now(),
constraint vehicles_id_pkey primary key (vehicles_id),
constraint vehicles_code_unique unique (vehicles_code, driver_id),
CONSTRAINT gps_sensors_vehicles_fkey FOREIGN KEY (gps_sensors_id) REFERENCES public.gps_sensors (gps_sensors_id) 
	MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
comment on table public.vehicles is 'Table that stores vehicle specification.';

create table public.gps_sensors(
gps_sensors_id serial,
gps_sensors_code varchar(10),
purchase_date date,
frequency integer(5),
vendor varchar(20),
model varchar(20),
sim unsigned integer(20),
insert_timestamp timestamp with time zone default now(),
constraint gps_sensors_id_pkey primary key (gps_sensors_id),
constraint gps_sensors_code_unique unique (gps_sensors_code),
CONSTRAINT purchase_date_check CHECK (purchase_date > '2015-01-01'::date)
);
comment on table public.gps_sensors is 'Table that stores gps specification.';

create table public.gps_data_vehicles(
gps_data_vehicles_id serial,
gps_sensors_id integer(20),
vehicles_id integer(20),
acquisition_time time with time zone,
longitude double precision(10,4),
latitude double precision(10,4),
geom geometry,
insert_timestamp timestamp with time zone default now(),
constraint gps_data_vehicles_pkey primary key (gps_data_vehicles_id),
CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 4326),
CONSTRAINT gps_data_vehicles_vehicles_fkey FOREIGN KEY (vehicles_id) REFERENCES public.vehicles (vehicles_id) 
MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
CONSTRAINT gps_data_vehicles_gps_sensors_fkey FOREIGN KEY (gps_sensors_id) REFERENCES public.gps_sensors (gps_sensors_id) 
MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
comment on table public.gps_data_vehicles is 'Table that stores vehicle positions';

---
--Improving Searching
---

CREATE INDEX gps_sensors_code_index
	ON public.gps_data USING btree (gps_sensors_code);
	
	
---
---Shapefile tables
---
create table public.hydrants(
hydrants_id serial,
status varchar(20),
outlets integer(5),
size_outlets double precision(5,2),
inspection_dates date,
geom geometry,
remarks varchar(50),
constraint hydrants_id_pkey primary key (hydrants_id)
);
comment on table public.hydrants is 'Table that stores hydrants information';

create table public.roads(
roads_id serial,
geom geometry,

constraint roads_id_pkey primary key (roads_id) 
);
comment on table public.roads is 'Table that stores roads information.';

---
---Automation
---
CREATE SCHEMA tools
	AUTHORIZATION postgres;
COMMENT ON SCHEMA tools 
IS 'Schema that hosts all the functions and ancillary tools used for the 
database.';
	
CREATE OR REPLACE FUNCTION tools.gps_data2gps_data_vehicles()
RETURNS trigger AS
$BODY$ begin
INSERT INTO public.gps_data_vehicles (
	gps_sensors_id, vehicles_id, acquisition_time, longitude, latitude) 
SELECT
	gps_sensors.gps_sensors_id,
	vehicles.vehicles_id,
	gps_data.insert_timestamp, 
	gps_data.longitude,
	gps_data.latitude
FROM
	public.vehicles, 
	public.gps_data, 
	public.gps_sensors
WHERE
	gps_data.gps_sensors_code = gps_sensors.gps_sensors_code AND
	gps_sensors.gps_sensors_id = vehicles.gps_sensors_id AND
	(
		--is not null
		gps_data.longitude !=0 and
		gps_data.latitude !=0
	);
RETURN NULL;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
COMMENT ON FUNCTION tools.gps_data2gps_data_vehicles() 
IS 'Automatic upload data from gps_data to gps_data_vehicles.';


CREATE TRIGGER trigger_gps_data_upload
	AFTER INSERT
	ON public.gps_data
	FOR EACH ROW
	EXECUTE PROCEDURE tools.gps_data2gps_data_vehicles();
COMMENT ON TRIGGER trigger_gps_data_upload ON public.gps_data
IS 'Upload data from gps_data to gps_data_vehicles whenever a new record is 
inserted.';

CREATE OR REPLACE FUNCTION tools.new_gps_data_vehicles()
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
COMMENT ON FUNCTION tools.new_gps_data_vehicles()
IS 'When called by a trigger (insert_gps_locations) this function populates
the field geom using the values from longitude and latitude fields.';
---respective trigger
CREATE TRIGGER insert_gps_location
BEFORE INSERT
ON public.gps_data_vehicles
FOR EACH ROW
EXECUTE PROCEDURE tools.new_gps_data_vehicles();
COMMENT ON TRIGGER trigger_insert_gps_location ON public.gps_data_vehicles
IS 'triggers tools.new_gps_data_vehicles function to populates the field geom 
using the values from longitude and latitude fields when a record is inserted.';

SELECT ST_Buffer(the_geom, 30000)
FROM usa_states
WHERE state = 'California'

SELECT ST_Union(ST_Buffer(ST_Centroid(the_geom), 200000))
FROM usa_states

SELECT ST_Intersection(s.the_geom,r.the_geom), s.state, r.river
FROM usa_states as s, usa_rivers as r
WHERE s.state = 'Texas'
