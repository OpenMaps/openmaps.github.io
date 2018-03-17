---creating database called postgres
CREATE DATABASE postgres
ENCODING = 'UTF8';

---creating schema called main
CREATE SCHEMA main;
COMMENT ON SCHEMA public IS 'Schema that stores all the GPS tracking core 
data.';
---creating table called parcels
create table public.parcels(
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
comment on table public.parcels is 'Table for storing land information and aucillary information about the owners';	
	
