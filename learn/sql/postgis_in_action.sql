SELECT postgis_full_version();
---"POSTGIS="2.1.7 r13414" GEOS="3.4.2-CAPI-1.8.2 r3922" 
---PROJ="Rel. 4.8.0, 6 March 2012" GDAL="GDAL 1.11.1, 
---released 2014/09/24" LIBXML="2.7.8" LIBJSON="UNKNOWN" RASTER"
SELECT version();
---"PostgreSQL 9.4.0, compiled by Visual C++ build 1800, 32-bit"
---stores points in longitude, latitude
SELECT ST_Point(1, 2) AS MyFirstPoint;
SELECT ST_SetSRID(ST_Point(-77.036548, 38.895108),4326);
SELECT ST_GeomFromText('POINT(-77.036548 38.895108)', 4326); ---slower & less accurate
---0101000020E6100000FD2E6CCD564253C0A93121E692724340
SELECT ST_AsEWKT('0101000020E6100000FD2E6CCD564253C0A93121E692724340'); ---or ST_AsText
---SRID=4326;POINT(-77.036548 38.895108)
SELECT ST_GeomFromText('LINESTRING(-14 21,0 0,35 26)') AS MyCheckMark;
---
SELECT ST_GeomFromText('LINESTRING(52 218, 139 82, 262 207, 245 261, 207 267,
153 207, 125 235, 90 270, 55 244, 51 219, 52 218)') AS HeartLine;
---WKT representation of a polygon is that it has
---one additional set of parentheses that a linestring doesn’t have
SELECT ST_GeomFromText('POLYGON((0 1,1 -1,-1 -1,0 1))') As MyTriangle;
---A polygon can have holes, and each hole needs its own set of parentheses.
SELECT ST_GeomFromText('POLYGON((52 218, 139 82, 262 207, 245 261,
207 267, 153 207, 125 235, 90 270,
55 244, 51 219, 52 218))') As HeartPolygon;
---Geometry data, can be stored in any spatial reference system
---For geometry data, we often need to transform lon lat
---values to a planar-based spatial reference system that’s suitable for planar measurement.
---Data in the geography data type must always be stored in WGS 84 Lon Lat degrees
---all measurements in geography are expressed in meters
---use the geography data type for storage, you must load it as geometry, transform it,
---and then cast it to geography.
----
---Loading comma-separated data
CREATE SCHEMA ch01; ---create logical container
---create lookup table to map franchise codes to meaningful names 
CREATE TABLE ch01.lu_franchises(
franchise_code char(1) PRIMARY KEY,
franchise_name varchar(100));
---add franchise_name
INSERT INTO ch01.lu_franchises(franchise_code, franchise_name)
VALUES ('b', 'Burger King'),
('c', 'Carl''s Jr'),
('h', 'Hardee''s'),
('i', 'In-N-Out'),
('j', 'Jack in the Box'),
('k', 'Kentucky Fried Chicken'),
('m', 'McDonald''s'),
('p', 'Pizza Hut'),
('t', 'Taco Bell'),
('w', 'Wendy''s');
---table holds locations
CREATE TABLE ch01.fastfoods
(
franchise char(1) NOT NULL,
lat double precision,
lon double precision
);
---Use SQL copy flat file data into postgreSQL
COPY ch01.fastfoods FROM '/data/fastfoods.csv' DELIMITER ',';
---Use psql, the command-line tool copy flat file data into postgreSQL
\copy ch01.fastfoods from '/data/fastfoods.csv' DELIMITER AS ','

---ADDING CONSTRAINTS
ALTER TABLE ch01.fastfoods ADD COLUMN ff_id SERIAL PRIMARY KEY;
---Adding CASCADE UPDATE DELETE rules when we add
---foreign key relationships will allow us to change the franchise codes for our franchises
--if we want and have those update the fastfoods table automatically
ALTER TABLE ch01.fastfoods
ADD CONSTRAINT fk_fastfoods_franchise
FOREIGN KEY (franchise)
REFERENCES ch01.lu_franchises (franchise_code)
ON UPDATE CASCADE ON DELETE RESTRICT;
---create an index to make the join between the two tables a bit more efficient:
CREATE INDEX fki_fastfoods_franchise ON ch01.fastfoods(franchise);
---Spatializing flat file 

-----Using the geometry data type to store data
SELECT AddGeometryColumn('ch01', 'fastfoods' , 'geom', 2163, 'POINT',2); ---add column
UPDATE ch01.fastfoods SET geom = ST_Transform(
ST_GeomFromText('POINT(' || lon || ' ' || lat || ')',4326), 2163); ---use equal area planar proj 2163
CREATE INDEX idx_fastfoods_geom
ON ch01.fastfoods USING gist(geom);  ---general maintenance

-----Using the geography data type to store data
ALTER TABLE ch01.fastfoods ADD COLUMN geog geography(POINT,4326);  ---add column
UPDATE ch01.fastfoods SET geog = ST_GeogFromText('SRID=4326;POINT(' || lon
|| ' ' || lat || ')'); --- use geodetic
CREATE INDEX idx_fastfoods_geog 
ON ch01.fastfoods USING gist(geog); ----general maintenance

---vacuum-analyzing step is a process that gets rid of dead rows and updates the
---planner statistics. good practice to do this after bulk uploads
vacuum analyze ch01.fastfoods;

---Loading data from spatial data sources
---Neither the shp2pgsql command line nor the GUI has transformation abilities
shp2pgsql -s 4269 -g geom_4269 /data/roadtrl020.shp ch01.roads |
 psql -h localhost -U postgres -p root -d postgres
 
---Using the geometry data type to store roads data
SELECT AddGeometryColumn('ch01', 'roads', 'geom', 2163,'MULTILINESTRING',2); ---add column
UPDATE ch01.roads
SET geom = ST_Transform(geom_4269, 2163); ---use equal area planar meters
SELECT DropGeometryColumn('ch01', 'roads', 'geom_4269');  ---drop the old column
CREATE INDEX idx_roads_geom ON ch01.roads USING gist(geom);  ---general maintenance

vacuum analyze ch01.roads;

---LOADING SPATIAL DATA INTO THE GEOGRAPHY DATA TYPE
shp2pgsql -G -g geog /data/roadtrl020.shp ch01.roads_geog |
	psql -h localhost -U postgres -p 5432 -d postgres
	
vacuum analyze ch01.roads_geog;

---Using spatial queries to analyze data
--Proximity queries
--HOW MANY FAST-FOOD RESTAURANTS BY CHAIN ARE WITHIN ONE MILE OF A MAIN HIGHWAY?
SELECT ft.franchise_name,
COUNT(DISTINCT ff.ff_id) As tot   ---distinct count
FROM ch01.fastfoods As ff
INNER JOIN ch01.lu_franchises As ft  ---non spatial join
ON ff.franchise = ft.franchise_code
INNER JOIN ch01.roads As r                  ---spatial join
ON ST_DWithin(ff.geom, r.geom, 1609*1)
WHERE r.feature LIKE 'Principal Highway%'
GROUP BY ft.franchise_name
ORDER BY tot DESC;
-------results
---franchise_name tot
--McDonald's 5343
--Burger King 3049
--Pizza Hut 2920
--Wendy's 2446
--Taco Bell 2428
--Kentucky Fried Chicken 2371

---WHICH HIGHWAY HAS THE LARGEST NUMBER OF FAST-FOOD RESTAURANTS WITHIN
--A HALF-MILE RADIUS?
SELECT r.name,
COUNT(DISTINCT ff.ff_id) As tot  ---distinct count
FROM ch01.fastfoods As ff
INNER JOIN ch01.roads As r
ON ST_DWithin(ff.geom, r.geom, 1609*0.5)     ----within a half mile
WHERE r.feature LIKE 'Principal Highway%'
GROUP BY r.name
ORDER BY tot DESC LIMIT 1;

---Buffer
SELECT COUNT(DISTINCT ff.ff_id) As tot
FROM ch01.fastfoods As ff
INNER JOIN ch01.roads As r
ON ST_DWithin(ff.geom, r.geom, 1609*10)
WHERE r.name = 'US Route 1' AND ff.franchise = 'h'
AND r.state = 'MD';
---
SELECT r.gid, r.name, ST_AsBinary(r.geom) As wkb
FROM ch01.roads As r
WHERE r.name = 'US Route 1' AND r.state = 'MD';
---
SELECT
ST_AsBinary(ff.geom) As wkb
FROM ch01.fastfoods As ff
WHERE EXISTS(SELECT r.gid
FROM ch01.roads As r
WHERE ST_DWithin(ff.geom, r.geom, 1609*10)
AND r.name = 'US Route 1' AND r.state = 'MD'
AND ff.franchise = 'h');
---
SELECT
ST_AsBinary(ST_Union(ST_Buffer(r.geom,1609*10))) As wkb
FROM ch01.roads As r
WHERE r.name = 'US Route 1' AND r.state = 'MD';

---
CREATE TABLE my_geometries
(id serial NOT NULL PRIMARY KEY, 
name varchar(20)
);
---AddGeometryColumn('db','table','column',srid,'datatype',DIMENSIONS)
---point
SELECT AddGeometryColumn('public','my_geometries','my_points',0,'POINT',2);
INSERT INTO my_geometries (name,my_points)
VALUES ('Home',ST_GeomFromText('POINT(0 0)'));
INSERT INTO my_geometries (name,my_points)
VALUES ('Pizza 1',ST_GeomFromText('POINT(1 1)')) ;
INSERT INTO my_geometries (name,my_points)
VALUES ('Pizza 2',ST_GeomFromText('POINT(1 -1)'));

---linestring
SELECT AddGeometryColumn ('public','my_geometries','my_linestrings',0,'LINESTRING',2);
INSERT INTO my_geometries (name,my_linestrings)
VALUES ('Linestring Open',
ST_GeomFromText('LINESTRING(0 0,1 1,1 -1)'));
INSERT INTO my_geometries (name,my_linestrings)
VALUES ('Linestring Closed',
ST_GeomFromText('LINESTRING(0 0,1 1,1 -1, 0 0)'));

---polygons
SELECT AddGeometryColumn('public','my_geometries', 'my_polygons',0,'POLYGON',2);
INSERT INTO my_geometries (name,my_polygons)
VALUES ('Triangle',
ST_GeomFromText('POLYGON((0 0, 1 1, 1 -1, 0 0))'));
----many polygons
INSERT INTO my_geometries (name,my_polygons)
VALUES ('Square with 2 holes',
ST_GeomFromText('POLYGON(
(-0.25 -1.25,-0.25 1.25,2.5 1.25,2.5 -1.25,-0.25 -1.25),
(2.25 0,1.25 1,1.25 -1,2.25 0),(1 -1,1 1,0 0,1 -1))'));
---MULTI
--same type geometries
----MULTIPOINTS
MULTIPOINT(-1 1, 0 0, 2 3)
MULTIPOINT(-1 1 3 4, 0 0 1 2, 2 3 1 2)
MULTIPOINT(-1 1 3, 0 0 1, 2 3 1)
MULTIPOINTM(-1 1 4, 0 0 2, 2 3 2)
----MULTILINESTRINGS
---extra sets of parentheses in the WKT representation of a multilinestring that separate each individual
--linestring in the set.
MULTILINESTRING((0 0,0 1,1 1),(-1 1,-1 -1))
MULTILINESTRING((0 0 1 1,0 1 1 2,1 1 1 3),(-1 1 1 1,-1 -1 1 2))
MULTILINESTRINGM((0 0 1,0 1 2,1 1 3),(-1 1 1,-1 -1 2))
----MULTIPOLYGONS
----we use parentheses to represent each ring of a polygon
MULTIPOLYGON(((2.25 0,1.25 1,1.25 -1,2.25 0)),
((1 -1,1 1,0 0,1 -1))) 
MULTIPOLYGON(((2.25 0 1,1.25 1 1,1.25 -1 1,2.25 0 1)),
((1 -1 2,1 1 2,0 0 2,1 -1 2)) )
MULTIPOLYGON(((2.25 0 1 1,1.25 1 1 2,1.25 -1 1 1,2.25 0 1 1)),
((1 -1 2 1,1 1 2 2,0 0 2 3,1 -1 2 4))
MULTIPOLYGONM(((2.25 0 1,1.25 1 2,1.25 -1 1,2.25 0 1)),
((1 -1 1,1 1 2,0 0 3,1 -1 4)) )
---GEOMETRYCOLLECTION
-- PostGIS data type that can contain heterogeneous geometries.
---Forming geometrycollections from constituent 
SELECT ST_AsText(ST_Collect(the_geom))
FROM (
SELECT ST_GeomFromText('MULTIPOINT(-1 1, 0 0, 2 3)') As the_geom
UNION ALL
SELECT ST_GeomFromText('MULTILINESTRING((0 0,0 1,1 1),
(-1 1,-1 -1))') As the_geom
UNION ALL
SELECT ST_GeomFromText('POLYGON((-0.25 -1.25,-0.25 1.25,
2.5 1.25,2.5 -1.25,-0.25 -1.25),
(2.25 0,1.25 1,1.25 -1,2.25 0),
(1 -1,1 1,0 0,1 -1))') As the_geom) As foo;
---Output:
GEOMETRYCOLLECTION(MULTIPOINT(-1 1,0 0,2 3),
MULTILINESTRING((0 0,0 1,1 1),(-1 1,-1 -1)),
POLYGON((-0.25 -1.25,-0.25 1.25,2.5 1.25,2.5 -1.25,-0.25 -1.25),
(2.25 0,1.25 1,1.25 -1,2.25 0),(1 -1,1 1,0 0,1 -1)))
----E stands for “extended.”
SELECT ST_AsEWKT(ST_Collect(the_geom)) 
FROM (
SELECT ST_GeomFromEWKT('MULTIPOINTM(-1 1 4, 0 0 2, 2 3 2)') As the_geom
UNION ALL
SELECT ST_GeomFromEWKT('MULTILINESTRINGM((0 0 1,0 1 2,1 1 3),
(-1 1 1,-1 -1 2))') As the_geom
UNION ALL
SELECT ST_GeomFromEWKT('POLYGONM((-0.25 -1.25 1,-0.25 1.25 2,
2.5 1.25 3,2.5 -1.25 1,-0.25 -1.25 1),
(2.25 0 2,1.25 1 1,1.25 -1 1,2.25 0 2),
(1 -1 2,1 1 2,0 0 2,1 -1 2))') As the_geom) As foo;
---Output:
GEOMETRYCOLLECTIONM(MULTIPOINT(-1 1 4,0 0 2,2 3 2),
MULTILINESTRING((0 0 1,0 1 2,1 1 3),(-1 1 1,-1 -1 2)),
POLYGON((-0.25 -1.25 1,-0.25 1.25 2,2.5 1.25 3,2.5 -1.25 1,
-0.25 -1.25 1), (2.25 0 2,1.25 1 1,1.25 -1 1,2.25 0 2),
(1 -1 2,1 1 2,0 0 2,1 -1 2)))
---Curved geometries
--CIRCULARSTRING
--Building circularstrings
SELECT AddGeometryColumn ('public','my_geometries','my_circular_strings',0,'CIRCULARSTRING',2);
INSERT INTO my_geometries(name,my_circular_strings)
VALUES ('Circle',
ST_GeomFromText('CIRCULARSTRING(0 0,2 0, 2 2, 0 2, 0 0)')),
('Half Circle',
ST_GeomFromText('CIRCULARSTRING(2.5 2.5,4.5 2.5, 4.5 4.5)')),
('Several Arcs',
ST_GeomFromText('CIRCULARSTRING(5 5,6 6,4 8, 7 9, 9.5 9.5,
11 12, 12 12)'));
---COMPOUNDCURVES
SELECT AddGeometryColumn ('public','my_geometries','my_compound_curves',0,'COMPOUNDCURVE',2);
INSERT INTO my_geometries(name,my_compound_curves)
VALUES ('Road with curve',
ST_GeomFromText('COMPOUNDCURVE((2 2, 2.5 2.5),
CIRCULARSTRING(2.5 2.5,4.5 2.5, 3.5 3.5), (3.5 3.5, 2.5 4.5, 3 5))'));
---CURVEPOLYGON
SELECT AddGeometryColumn ('public','my_geometries','my_curve_polygons',0,'CURVEPOLYGON',2);
INSERT INTO my_geometries(name,my_curve_polygons)
VALUES ('Solid Circle', ST_GeomFromText('CURVEPOLYGON(
CIRCULARSTRING(0 0,2 0, 2 2, 0 2, 0 0))')),
('Circle t hole',
ST_GeomFromText('CURVEPOLYGON(CIRCULARSTRING(2.5 2.5,4.5 2.5,
4.5 3.5, 2.5 4.5, 2.5 2.5),
(3.5 3.5, 3.25 2.25, 4.25 3.25, 3.5 3.5) )') ),
('T arcish hole',
ST_GeomFromText('CURVEPOLYGON((-0.5 7, -1 5, 3.5 5.25, -0.5 7),
CIRCULARSTRING(0.25 5.5, -0.25 6.5, -0.5 5.75, 0 5.75, 0.25 5.5))'));

---ORGANISING SPATIAL DATA
--1. Table inheritance model.
-- first create a parent table for all roads
create table public.roads(
gid serial primary key,
road_name character varying(100),
geom geometry(LineString,4269)
);
---OR
CREATE TABLE public.roads(
gid serial PRIMARY KEY, 
road_name character varying(100)
);
SELECT AddGeometryColumn('public', 'roads', 'geom', 4269, 'LINESTRING',2);
---Two child tables
--first child will store roads in the 1st state
CREATE TABLE public.roads_NE(
CONSTRAINT pk PRIMARY KEY (gid),
state character varying
)
INHERITS (roads);
--constraints
ALTER TABLE public.roads_NE
ADD CONSTRAINT chk CHECK (state
IN ('MA', 'ME', 'NH', 'VT', 'CT', 'RI'));
--2nd child will store roads in the 2nd state
CREATE TABLE public.roads_SW(
CONSTRAINT pk PRIMARY KEY (gid),
state character varying
)
INHERITS (roads);
ALTER TABLE public.roads_SW
ADD CONSTRAINT chk CHECK (state IN ('AZ', 'NM', 'NV'));
---Demonstrate constraint exclusion
SELECT gid, road_name, geom FROM roads WHERE state = 'MA';

---Modeling a real city
---1. Modeling using a heterogeneous geometry column
CREATE TABLE ch03.paris_hetero(
gid serial NOT NULL,
osm_id integer, geom geometry,
ar_num integer, 
tags hstore,
CONSTRAINT paris_hetero_pk PRIMARY KEY (gid),
CONSTRAINT enforce_dims_geom CHECK (st_ndims(geom) = 2),
CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32631)
);
---Region tagging and clipping data to a specific arrondissement
--Insert data; clip to specific arrondissement
INSERT INTO ch03.paris_hetero(osm_id, geom, ar_num, tags)
SELECT o.osm_id, ST_Intersection(o.geom, a.geom) As geom,
a.ar_num, o.tags
FROM
(SELECT osm_id, ST_Transform(way, 32631) As geom, tags FROM
planet_osm_line) AS O INNER JOIN ch03.arrondissements AS A ON
(ST_Intersects(o.geom, a.geom));
-- repeat for planet_osm_polygon, planet_osm_point

---Add indexes and update statistics
CREATE INDEX idx_paris_hetero_geom
ON ch03.paris_hetero USING gist(geom);
CREATE INDEX idx_paris_hetero_tags
ON ch03.paris_hetero USING gist(tags);
VACUUM ANALYZE ch03.paris_hetero;

----
SELECT ar_num, COUNT(DISTINCT osm_id) As compte
FROM ch03.paris_hetero
GROUP BY ar_num;
---create a view that promotes the two tags, name and tourism, into
---two text data columns
CREATE OR REPLACE VIEW ch03.vw_paris_points AS
SELECT gid, osm_id, ar_num, geom,
tags->'name' As place_name,
tags->'tourism' As tourist_attraction
FROM ch03.paris_hetero
WHERE ST_GeometryType(geom) = 'ST_Point';
---register views in the geometry_columns table just as you can with tables.
SELECT populate_geometry_columns('ch03.vw_paris_points');

---2.Modeling using homogeneous geometry columns
--Breaking our data into separate tables with homogeneous geometry columns
CREATE TABLE ch03.paris_points(
gid SERIAL PRIMARY KEY,
osm_id integer, 
ar_num integer,
feature_name varchar(200), 
feature_type varchar(50)
);
SELECT AddGeometryColumn('ch03', 'paris_points', 'geom', 32631,'POINT', 2);

INSERT INTO ch03.paris_points(
osm_id, ar_num, geom,feature_name,feature_type)
SELECT osm_id, ar_num, geom, tags->'name' As feature_name,
COALESCE(tags->'tourism', tags->'railway',
'other')::varchar(50) As feature_type
FROM ch03.paris_hetero
WHERE ST_GeometryType(geom) = 'ST_Point';
---to have a complete homogeneous solution, create similar tables for
--paris_polygons and paris_linestrings.
SELECT ar_num, COUNT(DISTINCT osm_id) As compte FROM
(SELECT ar_num, osm_id FROM paris_points
UNION ALL
SELECT ar_num, osm_id FROM paris_polygons
UNION ALL
SELECT ar_num, osm_id FROM paris_linestrings
) As X
GROUP BY ar_num;

---3. Modeling using inheritance
--create an abstract parent table to store attributes that all of its children will share
CREATE TABLE ch03.paris(
gid SERIAL PRIMARY KEY, 
osm_id integer, 
ar_num integer, 
feature_name varchar(200), 
feature_type varchar(50), 
geom geometry
);
ALTER TABLE ch03.paris
ADD CONSTRAINT enforce_dims_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE ch03.paris
ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32631);

---create child tables. paris_points, paris_linestrings & paris_polygons
--create an inherited table
CREATE TABLE ch03.paris_polygons(
tags hstore,
CONSTRAINT paris_polygons_pk PRIMARY KEY (gid)
)
INHERITS (ch03.paris);
--disinherit from parent
ALTER TABLE ch03.paris_polygons NO INHERIT ch03.paris;
--load
INSERT INTO ch03.paris_polygons(
osm_id, ar_num, geom,tags, feature_name, feature_type)
SELECT osm_id, ar_num, ST_Multi(geom) As geom,
tags, tags->'name',
COALESCE(tags->'tourism', tags->'railway',
'other')::varchar(50) As feature_type
FROM ch03.paris_hetero
WHERE ST_GeometryType(geom) LIKE '%Polygon';
SELECT populate_geometry_columns('ch03.paris_polygons'::regclass);
--reinherit
ALTER TABLE ch03.paris_polygons INHERIT ch03.paris;
---Adding another child and additional constraints
--create child table
CREATE TABLE ch03.paris_linestrings(
CONSTRAINT paris_linestrings_pk PRIMARY KEY (gid)
) INHERITS (ch03.paris);
--add geometry type constraint
ALTER TABLE ch03.paris_linestrings
ADD CONSTRAINT enforce_geotype_geom
CHECK (geometrytype(geom) = 'LINESTRING'::text);
--register geometry column
SELECT populate_geometry_columns('ch03.paris_linestrings'::regclass);

---Inheritance query advantage
SELECT ar_num, COUNT(DISTINCT osm_id) As compte
FROM ch03.paris
GROUP BY ar_num;
--query child
SELECT ar_num, COUNT(DISTINCT osm_id) As compte
FROM ch03.paris_polygons
GROUP BY ar_num;
---ADOPTION
--drop old gid
ALTER TABLE ch03.paris_points DROP COLUMN gid;
--add new gid based on parent's sequence
ALTER TABLE ch03.paris_points ADD COLUMN gid integer
PRIMARY KEY NOT NULL DEFAULT nextval
('ch03.paris_gid_seq');
--adoption
ALTER TABLE ch03.paris_points INHERIT ch03.paris;
--add a spatial index
CREATE INDEX idx_paris_points_geom
ON ch03.paris_points USING gist (geom);

---ADDING COLUMNS TO THE PARENT
ALTER TABLE ch03.paris ADD COLUMN tags hstore;
--When we do this, we’ll get a notice:
--merging definition of column "tags" for child "paris_polygons"


---Rules rewrite an SQL statement. 
---Triggers run a function for each affected row.
---###Using rules##
---Making views updateable with rules
--Read only view
CREATE OR REPLACE VIEW ch03.stations
AS
SELECT gid, osm_id, ar_num, feature_name, geom
FROM ch03.paris_points
WHERE feature_type = 'station';
--insertable view
CREATE OR REPLACE RULE rule_stations_insert AS
ON INSERT TO ch03.stations
DO INSTEAD /*rule do-instead*/
INSERT INTO ch03.paris_points(gid, osm_id, ar_num,
feature_name, feature_type, geom)
VALUES (DEFAULT, NEW.osm_id, NEW.ar_num,
NEW.feature_name, 'station', NEW.geom);
--deleteable view
CREATE OR REPLACE RULE rule_stations_delete AS
ON DELETE TO ch03.stations
DO INSTEAD /*rule do-instead*/
DELETE FROM ch03.paris_points
WHERE gid = OLD.gid AND feature_type = 'station';
--updateable view
CREATE OR REPLACE RULE rule_stations_update AS
ON UPDATE TO ch03.stations
DO INSTEAD /*rule do-instead*/
UPDATE ch03.paris_points
SET gid = NEW.gid, osm_id = NEW.osm_id,
ar_num = NEW.ar_num,
feature_name = NEW.feature_name,
geom = NEW.geom
WHERE gid = OLD.gid AND feature_type = 'station';

---NEW and OLD record variables in rules and triggers
--Both rules and triggers can have two record variables called NEW and OLD. 
--For INSERT FOR EACH ROW events, only NEW is available. 
--For DELETE FOR EACH ROW events, only OLD is available. 
--For UPDATE FOR EACH ROW events, both NEW and OLD are available.

--Let’s take our view for a test drive. 
--We start with a DELETE from the view as follows:
DELETE FROM ch03.stations;
--The database query engine automatically rewrites this as
DELETE FROM ch03.paris_points WHERE feature_type = 'station';
--Our stations have all vanished. We next add back our stations as follows:
INSERT INTO ch03.stations(osm_id, feature_name, geom)
SELECT osm_id, tags->'name', geom
FROM ch03.paris_hetero
WHERE tags->'railway' = 'station';
--With the rewrite, our insert becomes
INSERT INTO ch03.paris_points(osm_id,feature_name, feature_type, geom)
VALUES (NEW.osm_id, NEW.ar_num, NEW.feature_name, 'stations', NEW.geom)

---###Using triggers###
-- three core events of INSERT, UPDATE,and DELETE to six: 
--BEFORE INSERT, AFTER INSERT, BEFORE UPDATE, AFTER UPDATE, BEFORE DELETE, and AFTER DELETE. 
---BEFORE events fire prior to the execution of the triggering command
---AFTER events fire upon completion. Should you wish to perform an alternative action as you can with a DO INSTEAD rule, you’d create a trigger
---and bind it to the BEFORE event but throw out the resulting record. 


---PostgreSQL triggers are implemented as a special type of function called a trigger
---function and then bound to a table event

---REDIRECTING INSERTS WITH BEFORE TRIGGERS
CREATE TABLE ch03.paris_rejects
(
gid integer NOT NULL PRIMARY KEY,
osm_id integer,
ar_num integer,
feature_name varchar(200),
feature_type varchar(50),
geom geometry, tags hstore
);

---PL/PGSQL BEFORE INSERT trigger function to redirect insert
CREATE OR REPLACE FUNCTION ch03.trigger_paris_insert()
RETURNS trigger AS
$$
DECLARE
var_geomtype text;
BEGIN
---using temporary variables
var_geomtype := geometrytype(NEW.geom);
IF var_geomtype IN ('MULTIPOLYGON', 'POLYGON') THEN
NEW.geom := ST_Multi(NEW.geom);
INSERT INTO ch03.paris_polygons(gid, osm_id,
ar_num, feature_name, feature_type, geom, tags)
SELECT gid, osm_id, ar_num, feature_name,
feature_type, geom, tags
---NEW is alias for table with new record
FROM (SELECT NEW.*) As foo;
ELSIF var_geomtype = 'POINT' THEN
INSERT INTO ch03.paris_points(gid, osm_id, ar_num,
feature_name, feature_type, geom, tags)
SELECT gid, osm_id, ar_num, feature_name,
feature_type, geom, tags
FROM (SELECT NEW.*) As foo;
ELSIF var_geomtype = 'LINESTRING' THEN
INSERT INTO ch03.paris_linestrings(gid, osm_id,
ar_num, feature_name, feature_type, geom,tags)
SELECT gid, osm_id, ar_num, feature_name,
feature_type, geom, tags
FROM (SELECT NEW.*) As foo;
ELSE
---non standard geometry types go into rejects table
INSERT INTO ch03.paris_rejects(gid, osm_id, ar_num,
feature_name, feature_type, geom, tags)
SELECT gid, osm_id, ar_num, feature_name,
feature_type, geom, tags
FROM (SELECT NEW.*) As foo;
END IF;
--Cancel original insert
RETURN NULL;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

---trigger 
CREATE TRIGGER trigger1_paris_insert 
BEFORE INSERT
ON ch03.paris FOR EACH ROW
EXECUTE PROCEDURE ch03.trigger_paris_insert();
---deleting data clause from parent and child tables when no foreign key constraints
TRUNCATE TABLE ch03.paris;
---insert
INSERT INTO ch03.paris (osm_id, geom, tags)
SELECT osm_id, geom, tags FROM ch03.paris_hetero;
---
--CREATING TABLES ON THE FLY WITH TRIGGERS
---Trigger that dynamically creates tables as needed
CREATE OR REPLACE FUNCTION ch03.trigger_paris_child_insert() 
RETURNS TRIGGER
AS $$
DECLARE
var_sql text;
var_tbl text;
BEGIN
---assign destination name to variable
var_tbl := TG_TABLE_NAME || '_ar'
|| lpad(NEW.ar_num::text, 2, '0');
---check if destination table exists
IF NOT EXISTS(SELECT * FROM information_schema.tables
WHERE table_schema = TG_TABLE_SCHEMA
AND table_name = var_tbl) THEN
var_sql := 'CREATE TABLE ' … ---[See Code Listing]
EXECUTE var_sql;
END IF;
---prepare and execute inserts SQL
var_sql := 'INSERT INTO ' || TG_TABLE_SCHEMA
|| '.' || var_tbl
|| '(gid, osm_id, ar_num, feature_name,
feature_type, geom, tags)
VALUES($1, $2, $3, $4, $5, $6, $7)';
EXECUTE var_sql USING NEW.gid, NEW.osm_id,
NEW.ar_num, NEW.feature_name, NEW.feature_type,
NEW.geom, NEW.tags;
---cancel original insert
RETURN NULL;
END;
$$ language plpgsql;

---Binding same trigger function to multiple tables
CREATE TRIGGER trig01_paris_child_insert 
BEFORE INSERT
ON ch03.paris_polygons FOR EACH ROW
EXECUTE PROCEDURE ch03.trigger_paris_child_insert();

CREATE TRIGGER trig01_paris_child_insert 
BEFORE INSERT
ON ch03.paris_points FOR EACH ROW
EXECUTE PROCEDURE ch03.trigger_paris_child_insert();

CREATE TRIGGER trig01_paris_child_insert 
BEFORE INSERT
ON ch03.paris_linestrings FOR EACH ROW
EXECUTE PROCEDURE ch03.trigger_paris_child_insert();

---Geometry functions
--Outputs
SELECT ST_AsGML(geom,5) as GML, 
ST_AsKML(geom,5) As KML, 
ST_AsGeoJSON(geom,5) As GeoJSON, 
ST_AsSVG(geom,0,5) As SVG_Absolute, 
ST_AsSVG(geom,1,5) As SVG_Relative, 
ST_GeoHash(geom) As Geohash
FROM (SELECT ST_GeomFromText('LINESTRING(2 48, 0 51)', 4326) As geom) foo;
--results"
--GML
"<gml:LineString srsName="EPSG:4326">
<gml:coordinates>2,48 0,51</gml:coordinates></gml:LineString>";
---KML
"<LineString><coordinates>2,48 0,51</coordinates></LineString>";
--GeoJSON
"{"type":"LineString","coordinates":[[2,48],[0,51]]}";
--SVG_Absolute
"M 2 -48 L 0 -51";
--SVG_Relative
"M 2 -48 l -2 -3";
--Geohash
"u"

---Example use of ST_SRID
SELECT ST_SRID(
ST_GeomFromText('POLYGON((1 1, 2 2, 2 0, 1 1))', 4326));
SELECT ST_SRID(geom) As srid, COUNT(*) As number_of_geoms
FROM sometable
GROUP BY ST_SRID(geom);
SELECT ST_SRID(geom) As srid,
---using ST_SetSRID to change SRID
ST_SRID(ST_SetSRID(geom,4326)) as srid_new
FROM (VALUES (
ST_GeomFromText('POLYGON((70 20, 71 21, 71 19, 70 20))',
4269)), (ST_Point(1,2))
) As foo (geom);
---Transform  WGS 84 lonlat and converts it to WGS 84 UTM Zone 18N meters:
SELECT ST_AsEWKT(ST_Transform(ST_GeomFromEWKT('SRID=4326;
LINESTRING(-73 41, -72 42)'), 32618));

---Differences between ST_GeometryType and GeometryType
SELECT ST_GeometryType(geom) As new_name, GeometryType(geom) As old_name
FROM (VALUES
(ST_GeomFromText('POLYGON((0 0, 1 1, 0 1, 0 0))')),
(ST_Point(1, 2)),
(ST_MakeLine(ST_Point(1, 2), ST_Point(1, 2))),
(ST_Collect(ST_Point(1, 2), ST_Buffer(ST_Point(1, 2),3))),
(ST_LineToCurve(ST_Buffer(ST_Point(1, 2), 3))),
(ST_LineToCurve(ST_Boundary(ST_Buffer(ST_Point(1, 2), 3)))),
(ST_Multi(ST_LineToCurve(ST_Boundary(ST_Buffer(ST_Point(1, 2),3)))))
) As foo (geom);

---Coordinate and geometry dimensions of various geometries
SELECT item_name, ST_Dimension(geom) As gdim, ST_CoordDim(geom) as cdim
FROM ( VALUES ('2d polygon' ,
ST_GeomFromText('POLYGON((0 0, 1 1, 1 0, 0 0))') ),
('2d polygon with hole' ,
ST_GeomFromText('POLYGON ((-0.5 0, -1 -1, 0 -0.7, -0.5 0),
(-0.7 -0.5, -0.5 -0.7, -0.2 -0.7, -0.7 -0.5))') ),
( '2d point', ST_Point(1,2) ),
( '2d line' , ST_MakeLine(ST_Point(1,2), ST_Point(3,4)) ),
( '2d collection', ST_Collect(ST_Point(1,2), ST_Buffer(ST_Point(1,2),3)) ),
( '2d curved polygon', ST_LineToCurve(ST_Buffer(ST_Point(1,2), 3)) ) ,
( '2d circular string',
ST_LineToCurve(ST_Boundary(ST_Buffer(ST_Point(1,2), 3))) ),
( '2d multicurve',
ST_Multi(ST_LineToCurve(
ST_Boundary(ST_Buffer(ST_Point(1,2), 3)))) ),
('3d polygon' ,
ST_GeomFromText('POLYGON((0 0 1, 1 1 1, 1 0 1, 0 0 1))') ),
('2dm polygon' ,
ST_GeomFromText('POLYGONM((0 0 1, 1 1 1.25, 1 0 2, 0 0 1))') ),
('3d(zm) polygon' ,
ST_GeomFromEWKT('POLYGON((0 0 1 1, 1 1 1 1.25, 1 0 1 2, 0 0 1 1))') ),
('4d (zm) multipoint' ,
ST_GeomFromEWKT('MULTIPOINT(1 2 3 4, 4 5 6 5, 7 8 9 6)') )
) As foo(item_name, geom);

---Example of ST_NPoints and ST_NumPoints
SELECT type, ST_NPoints(geom) As npoints,
ST_NumPoints(geom) As numpoints
FROM (VALUES ('LinestringM' ,
ST_GeomFromEWKT('LINESTRINGM(1 2 3, 3 4 5, 5 8 7, 6 10 11)')),
('Circularstring',
ST_GeomFromText('CIRCULARSTRING(2.5 2.5, 4.5 2.5, 4.5 4.5)')),
('Polygon (Triangle)',
ST_GeomFromText('POLYGON((0 1,1 -1,-1 -1,0 1))')),
('Multilinestring',
ST_GeomFromText('MULTILINESTRING ((1 2, 3 4, 5 6),
(10 20, 30 40))')),
('Collection', ST_Collect(
ST_GeomFromText('POLYGON((0 1,1 -1,-1 -1,0 1))'),
ST_Point(1,3)))
) As foo(type, geom);

---Measurement functions
--Planar measures for geometry types
ST_Length, 
ST_Length3D, 
ST_Area,
ST_Perimeter,
ST_3DClosestPoint,
ST_3DDistance, 
ST_3DIntersects, 
ST_3DShortestLine, and 
ST_3DLongestLine

SELECT ST_Length(geom) As length_2d, ST_Length3D(geom) As length_3d
FROM (VALUES(ST_GeomFromEWKT('LINESTRING(1 2 3, 4 5 6)')),
ST_GeomFromEWKT('LINESTRING(1 2, 4 5)'))) As foo(geom);

---Length2D ------Length3D
4.24264068711928 5.19615242270663
4.24264068711928 4.24264068711928

---Calculating the length of a multilinestring with different spheroids
SELECT sp_name, geom_name,
ST_Length_Spheroid(g.geom, s.the_spheroid) As sp3d_length, ST_Length3D(
ST_Transform(g.geom, 26986)) As ma_state_m,
ST_Length3D(ST_Transform(g.geom, 2163)) As us_nat_atl_m
FROM (VALUES ('2d line',
ST_GeomFromText('MULTILINESTRING((-71.205 42.531,-71.204 42.532),
(-71.21 42.52, -71.211 42.52))',4326)),
('3d line',
ST_GeomFromEWKT('SRID=4326;MULTILINESTRING((-71.205 42.531 10,
-71.205 42.531 15,-71.204 42.532 16, -71.204 42.532 18),
(-71.21 42.52 0,-71.211 42.52 0))') )
) As g(geom_name, geom)
CROSS JOIN
(VALUES ('grs 1980',
CAST('SPHEROID["GRS_1980",6378137,298.257222101]' As spheroid)),
('wg 1984',
CAST('SPHEROID["WGS_1984",6378137,298.257223563]' As spheroid) )
) As s(sp_name, the_spheroid);

---Results
--sp_name--geom_name-- sp3d_length-- ma_state_m-- us_nat_atl_m
grs 1980  2d line 220.337420025626 220.33319845914  220.759524564227
wg 1984   2d line 220.337387457848 220.33319845914  220.759524564227
grs 1980  3d line 227.341038849482 227.336817351126 227.763097850584
wg 1984   3d line 227.341006282557 227.336817351126 227.763097850584

---Comparing spheroid and sphere calculations in geography
SELECT name, ST_Length(geog) As sp3d_lengthspheroid,
ST_Length(geog, false) As sp3d_lengthsphere
FROM (VALUES ('2D Multilinestring',
ST_GeogFromText('SRID=4326;
MULTILINESTRING((-71.205 42.531, -71.204 42.532),
(-71.21 42.52, -71.211 42.52))')),
('3D Multilinestring',
ST_GeogFromText('SRID=4326;
MULTILINESTRING((-71.205 42.531 10, -71.205 42.531 15,
-71.204 42.532 16,-71.204 42.532 18),
(-71.21 42.52 0, -71.211 42.52 0))'))
) As foo (name, geog);

----Decomposition
---ST_Box2D and casting a box to a geometry
SELECT name, ST_Box2D(geom) As box,
ST_AsEWKT(CAST(geom As geometry)) As box_casted_as_geometry
FROM (
VALUES
('2D linestring', ST_GeomFromText('LINESTRING(1 2, 3 4)')),
('Vertical linestring', ST_GeomFromText('LINESTRING(1 2, 1 4)')),
('Point', ST_GeomFromText('POINT(1 2)')),
('Polygon', ST_GeomFromText('POLYGON((1 2, 3 4, 5 6, 1 2))')))
AS foo(name, geom);

--Results
--name --           box --        box_casted_as_geometry
2D linestring       BOX(1 2, 3 4) POLYGON((1 2, 1 4, 3 4, 3 2, 1 2))
Vertical linestring BOX(1 2, 1 4) LINESTRING(1 2, 1 4)
Point               BOX(1 2, 1 2) POINT(1 2)
Polygon             BOX(1 2, 5 6) POLYGON((1 2, 1 6, 5 6, 5 2, 1 2))

---Example of ST_Envelope
SELECT name, ST_Box2D(geom) AS box,
ST_AsEWKT(ST_Envelope(geom)) AS env
FROM (
VALUES
('2D linestring', ST_GeomFromText('LINESTRING(1 2, 3 4)')),
('Vertical linestring', ST_GeomFromText('LINESTRING(1 2, 1 4)')),
('Point', ST_GeomFromText('POINT(1 2)')),
('Polygon', ST_GeomFromText('POLYGON((1 2, 3 4, 5 6, 1 2))'))
)
AS foo(name, geom);

---Results
--name ---          box ---       env
2D linestring 		BOX(1 2, 3 4) POLYGON((1 2, 1 4, 3 4, 3 2, 1 2))
Vertical linestring BOX(1 2,1 4)  LINESTRING(1 2, 1 4)
Point 				BOX(1 2, 1 2) POINT(1 2)
Polygon 			BOX(1 2, 5 6) POLYGON((1 2, 1 6, 5 6, 5 2, 1 2))

---Coordinates
ST_X and ST_Y 

---Examples of ST_Boundary
SELECT name, ST_AsText(ST_Boundary(geom)) As WKT
FROM (VALUES
('Simple linestring',
ST_GeomFromText('LINESTRING(-14 21,0 0,35 26)')),
('Non-simple linestring',
ST_GeomFromText('LINESTRING(2 0,0 0,1 1,1 -1)')),
('Closed linestring',
ST_GeomFromText('LINESTRING(52 218, 139 82,
262 207, 245 261, 207 267, 153 207,
125 235, 90 270, 55 244, 51 219, 52 218)')),
('Polygon',
ST_GeomFromText('POLYGON((52 218, 139 82, 262 207,
245 261, 207 267, 153 207, 125 235, 90 270,
55 244, 51 219, 52 218))')),
('Polygon with holes',
ST_GeomFromText('POLYGON((-0.25 -1.25,-0.25 1.25,2.5 1.25,
2.5 -1.25,-0.25 -1.25),(2.25 0,1.25 1,1.25 -1,2.25 0),
(1 -1,1 1,0 0,1 -1))'))
)
AS foo(name, geom);

---name ---             WKT
Simple linestring 		MULTIPOINT(-14 21,35 26)
Non-simple linestring 	MULTIPOINT(2 0,1 -1)
Closed linestring 		MULTIPOINT EMPTY
Polygon 				LINESTRING(52 218,139 82,262 207,245 261,207 267,153 207,125 235,
						90 270,55 244,51 219,52 218)
Polygon with holes 		MULTILINESTRING((-0.25 -1.25,-0.25 1.25,2.5 1.25,2.5 -1.2 5,-0.25 -1.25),
						(2.25 0,1.25 1,1.25 -1,2.25 0),(1 -1,1 1,0 0,1 -1))
						
---Composition
--Making points
ST_Point,
ST_MakePointM,
ST_MakePoint
				---Point constructor functions

SELECT whale, ST_AsEWKT(spot) As spot
FROM
(VALUES
('Mr. Whale', ST_SetSRID(ST_Point(-100.499, 28.7015), 4326)),
('Mr. Whale with M as time',
ST_SetSRID(ST_MakePointM(-100.499, 28.7015, 5), 4326)),
('Mr. Whale with Z as depth',
ST_SetSRID(ST_MakePoint(-100.499, 28.7015, 0.5), 4326)),
('Mr. Whale with M and Z',
ST_SetSRID(ST_MakePoint(-100.499, 28.7015, 0.5, 5), 4326))
) As foo(whale, spot);				
		
---Making polygons
ST_MakePolygon, 
ST_BuildArea, and 
ST_Polygonize		

---ST_Polygonize , ST_BuildArea, ST_MakePolygon
SELECT geom
INTO example
FROM (
(VALUES(
ST_GeomFromText('LINESTRING(1 2, 3 4, 4 4, 1 2)')),
(ST_GeomFromEWKT('MULTILINESTRING((0 0, 4 4, 4 0, 0 0),
(2 1, 3 1, 3 2, 2 1))'))) ) As e(geom);
SELECT 'ST_MakePolygon (1)' As function,
ST_AsEWKT(
ST_MakePolygon(geom)) As polygon

FROM example
WHERE ST_GeometryType(geom) = 'ST_LineString'
UNION ALL
SELECT 'ST_MakePolygon (2)' As function,
ST_AsEWKT(
ST_MakePolygon(
ST_GeometryN(geom, 1),
ARRAY[(SELECT ST_GeometryN(geom, n)
FROM generate_series(2,
ST_NumGeometries(geom)) As n )])) As polygon

FROM example
WHERE ST_GeometryType(geom) = 'ST_MultiLineString'
UNION ALL
SELECT 'ST_BuildArea' As function,
ST_AsEWKT(ST_BuildArea(geom)) As polygon

FROM example
UNION ALL
SELECT 'ST_Polygonize' As function,
ST_AsEWKT(ST_Polygonize(geom)) As polygon
FROM example;


---Simplification
/*Simplification functions become important when passing geometries across 
the internet. Despite recent advances, bandwidth is still a precious commodity,
 especially with wireless devices.*/
ST_SnapToGrid, 
ST_Simplify, and
ST_SimplifyPreserveTopology  ---safeguards against oversimplification

---Coordinate rounding using ST_SnapToGrid
 SELECT pow(10, -1*n)*5 As tolerance,
ST_AsEWKT(ST_SnapToGrid(
ST_GeomFromEWKT('SRID=4326;
LINESTRING(-73.81309 41.74874, -73.81276 41.74893,
-73.812765 41.74895, -73.81307 41.74896)'),
pow(10, -1*n)*5)) As simplified_geometry
FROM generate_series(3,6) As n
ORDER BY tolerance;

---Results of the query in the previous code
---tolerance   ---simplified_geometry
0.000005 		SRID=4326; LINESTRING(-73.81309 41.74874, -73.81276 41.74893,
					-73.812765 41.74895, -73.81307 41.74896)
0.00005 		SRID=4326; LINESTRING(-73.8131 41.74875, -73.81275 41.74895,
					-73.81305 41.74895)
0.0005 			SRID=4326; LINESTRING(-73.813 41.7485, -73.813 41.749)
0.005 			NULL

---Simplifying geometries
--ST_Simplify and ST_SimplifyPreserveTopology assume planar coordinates
SELECT pow(2, n) as tolerance,
ST_AsText(ST_Simplify(geom, pow(2, n))) As ST_Simplify,
ST_AsText(
ST_SimplifyPreserveTopology(geom, pow(2, n)))
As ST_SimplifyPreserveTopology
FROM (SELECT
ST_GeomFromText('POLYGON((10 0, 20 0, 30 10, 30 20,
20 30, 10 30, 0 20, 0 10, 10 0))') As geom
) As foo CROSS JOIN generate_series(2,4) As n;

---Results of query in previous code
----tolerance --ST_Simplify
4 				POLYGON((10 0, 20 0, 30 10, 30 20, 20 30, 10 30, 0 20, 0 10, 10 0))
8 				POLYGON((10 0, 30 10, 20 30, 0 20, 10 0))
16 				NULL
---tolerance ---ST_SimplifyPreserveTopology
4 				POLYGON((10 0, 20 0, 30 10, 30 20, 20 30, 10 30, 0 20, 0 10, 10 0))
8 				POLYGON((10 0, 30 10, 20 30, 0 20, 10 0))
16 				POLYGON((10 0, 30 10, 20 30, 0 20, 10 0))

---Relationships between geometries
ST_Intersects,
ST_Intersection
---Intersections
SELECT ST_Intersects(g1.geom1,g1.geom2) As they_intersect,
GeometryType(
ST_Intersection(g1.geom1, g1.geom2)) As intersect_geom_type
FROM (SELECT ST_GeomFromText('POLYGON((2 4.5,3 2.6,3 1.8,2 0,
-1.5 2.2,0.056 3.222,-1.5 4.2,2 6.5,2 4.5))') As geom1,
ST_GeomFromText('LINESTRING(-0.62 5.84,-0.8 0.59)') As geom2) AS g1;

---Result of query in previous code
--they_intersect intersect_geom_type
t 				 MULTILINESTRING

---Clipping polygons with polygons
--Return our sales region diced up
--squares to dice
SELECT x || ' ' || y As grid_x_y,
CAST(ST_MakeBox2d(
ST_Point(-1.5 + x, 0 + y),
ST_Point(-1.5 + x + 2, 0 + y + 2)) As geometry) As geom2
FROM generate_series(0,3,2) As x
CROSS JOIN generate_series(0,6,2) As y;
SELECT ST_GeomFromText('POLYGON((2 4.5,3 2.6,3 1.8,2 0,-1.5 2.2,
0.056 3.222,-1.5 4.2,2 6.5,2 4.5))') As geom1;
---region
SELECT CAST(x AS text) || ' '
|| CAST(y As text) As grid_xy ,
ST_AsText(ST_Intersection(g1.geom1, g2.geom2)) As intersect_geom
FROM (SELECT ST_GeomFromText('POLYGON((2 4.5,3 2.6,3 1.8,2 0,
-1.5 2.2,0.056 3.222,-1.5 4.2,2 6.5,2 4.5))') As geom1) As g1
INNER JOIN (SELECT x, y, CAST(ST_MakeBox2d(ST_Point(-1.5 + x, 0 + y),
ST_Point(-1.5 + x + 2, 0 + y + 2)) As geometry) As geom2
FROM generate_series(0,3,2) As x
CROSS JOIN generate_series(0,6,2) As y) As g2
ON ST_Intersects(g1.geom1,g2.geom2) ;

---The result of the last query in listing 5.1
--grid_xy   intersect_geom
0 0 		POLYGON((0.5 0.942857142857143 ……))
2 0 		POLYGON((2.5 0.9,2 0,0.5 0.942857142857143,0.5 2,2.5 2,2.5 0.9))
0 2 		POLYGON((-1.18181818181818 2,-1.5 2.2,..))
2 2 		POLYGON((2.26315789473684 4,2.5 3.55,…))
0 4 		POLYGON((-1.18179959100204 4,-1.5 4.2,0.5 5….))
2 4 		POLYGON((2 4.5,2.26315789473684 4,0.5 4,0.5 5.51428571428571…))
2 6 		POLYGON((1.23913043478261 6,2 6.5,2 6,1.23913043478261 6))

---Finding N closest objects
SELECT r.name, ST_Distance(r.geom, loc.geom)/1000 As dist_km
FROM ch01.roads As r INNER JOIN
(SELECT ST_Transform(
ST_SetSRID(ST_Point(-118.42494, 37.31942), 4326),
2163) As geom) As loc
ON ST_DWithin(r.geom, loc.geom, 10000)
ORDER BY ST_Distance(r.geom, loc.geom)
LIMIT 5;

----Find the closest road to each location; search 10 kilometers out
SELECT DISTINCT ON(loc.loc_name, loc.loc_type) loc.loc_name,
loc.loc_type, r.road_name,
ST_Distance(r.the_geom, loc.geom)/1000 As dist_km
FROM ch05.loc LEFT JOIN
ch05.road As r
ON ST_DWithin(r.the_geom, loc.geom, 10000)
ORDER BY loc.loc_name, loc.loc_type,
ST_Distance(r.the_geom, loc.geom) ;

---Find the closest two roads to each station; search 1 kilometer out.
SELECT pid, land_type, row_num, road_name,
round(CAST(dist_km As numeric),2) As dist_km
FROM (SELECT
ROW_NUMBER() OVER (PARTITION BY loc.pid
ORDER BY ST_Distance(r.the_geom, loc.the_geom)) As row_num,
loc.pid,loc.land_type,r.road_name,
ST_Distance(r.the_geom, loc.the_geom)/1000 As dist_km
FROM ch05.land As loc
LEFT JOIN
ch05.road As r
ON ST_DWithin(r.the_geom, loc.the_geom, 1000)
WHERE loc.land_type = 'police station') As foo
WHERE foo.row_num < 3
ORDER BY pid, row_num;

---Results of query in listing 5.8
--Pid  -- land_type     --row_num --road_name 	--dist_km
000001038 police station 	1
000001202 police station 	1
000002997 police station 	1 		Main Rd 		0.25
000003927 police station 	1 		Main Rd 		0.07
000006442 police station 	1
000010131 police station 	1 		Main Rd 		0.23
000010131 police station 	2 		Curvy St 		0.34
000013872 police station 	1
000015423 police station 	1 		Elephantine Rd 	0.45

----Techniques to solve spatial problems
--USING ST_DISTANCE: FINDING DISTANCE OF BRIDGE TO VARIOUS CITIES
SELECT c.city, b.bridge_nam, ST_Distance(c.the_geom, b.the_geom) As dist_ft
FROM sf.cities AS c CROSS JOIN sf.bridges As b;

--USING ST_INTERSECTS: WHICH BAY AREA CITIES HAVE BRIDGES?
SELECT c.city, b.bridge_nam
FROM sf.cities AS c INNER JOIN
sf.bridges As b ON ST_Intersects(c.the_geom, b.the_geom);

--USING ST_DWITHIN: WHAT BRIDGES ARE WITHIN 1000 FEET OF SAN FRANCISCO?
SELECT DISTINCT c.city, b.bridge_nam,
ST_Distance(c.the_geom, b.the_geom) As dist_ft
FROM sf.cities AS c INNER JOIN sf.bridges As b
ON ST_DWithin(c.the_geom, b.the_geom,1000)
WHERE c.city = 'SAN FRANCISCO';
SELECT ST_Buffer(ST_Union(c.the_geom),1000) As sf_1000ft
FROM sf.cities As c
WHERE c.city = 'SAN FRANCISCO';

---Convert to different units of measurement
CREATE SCHEMA utility;
ALTER DATABASE postgis_in_action set search_path=public,utility;
---Create a simple units conversion table
set search_path=utility,public;
CREATE TABLE utility.lu_units (
unit character varying(50) NOT NULL PRIMARY KEY,
unit_to_meters numeric(10,4)
);
INSERT INTO lu_units (unit, unit_to_meters) VALUES ('mile', 1609.3400);
INSERT INTO lu_units (unit, unit_to_meters) VALUES ('kilometer', 1000);
INSERT INTO lu_units (unit, unit_to_meters) VALUES ('meter', 1);
INSERT INTO lu_units (unit, unit_to_meters) VALUES ('feet', 0.3048);

---Which bridges are within a half-mile of San Francisco?
SELECT DISTINCT c.city, b.bridge_nam,
ST_Distance(c.the_geom, b.the_geom) As dist_ft,
ST_Distance(c.the_geom, b.the_geom)*u.convfactor As dist_miles  ---convert feet to miles
FROM (
SELECT uf.unit_to_meters/um.unit_to_meters As convfactor   ---conversion table
FROM lu_units As uf CROSS JOIN lu_units As um
WHERE uf.unit = 'feet' and um.unit = 'mile') As u
CROSS JOIN sf.cities AS c
INNER JOIN sf.bridges As b ON (
ST_DWithin(c.the_geom, b.the_geom,0.5/u.convfactor))  ---convert 0.5 mile to 2640 feet
WHERE c.city = 'SAN FRANCISCO'
ORDER BY dist_miles;

---Example SQL function to convert between two units
CREATE OR REPLACE FUNCTION utility.units_from_to(
unitfrom character varying,
unitto character varying, 
thevalue double precision
)
RETURNS double precision AS
$$
WITH u(unit, unit_to_meters) AS
(VALUES ('mile', 1609.3400),
('kilometer', 1000),
('meter',1),
('feet', 0.3048)
)
SELECT ufrom.unit_to_meters/uto.unit_to_meters*$3
FROM
u As ufrom CROSS JOIN u As uto
WHERE ufrom.unit = $1 and uto.unit = $2;
$$
LANGUAGE 'sql' IMMUTABLE STRICT
COST 10;

----Using the unit conversion function
SELECT DISTINCT c.city, b.bridge_nam,
ST_Distance(c.the_geom, b.the_geom) As dist_ft,  ---feet to mile
units_from_to('feet','mile',
ST_Distance(c.the_geom, b.the_geom) ) As dist_miles
FROM
sf.cities AS c INNER JOIN sf.bridges As b ON (
ST_DWithin(c.the_geom, b.the_geom,
units_from_to('mile','feet',0.5) ) )   ----0.5 mile (mile to feet)
WHERE c.city = 'SAN FRANCISCO'
ORDER BY dist_miles;

--Data tagging
----Create dummy observation data
CREATE TABLE public.observations (
obsid serial PRIMARY KEY,
obs_name varchar(50),
obs_date date,
state_fips varchar(2),
state varchar(20));
SELECT
AddGeometryColumn('public','observations','the_geom','4326','POINT','2');

INSERT INTO public.observations(obs_name, obs_date, the_geom)
SELECT a.obs_name,
DATE '2008-01-01' + CAST(
CAST (random()*1000 As text) || ' days' As interval ),
ST_SetSRID(ST_Point(-170 + random()*200, 17
+ random()*50),4326) As the_geom
FROM unnest(ARRAY['parrot', 'parakeet', 'dove', 'pigeon',
'lizard monster', 'eagle', 'cat eater bird']) As a(obs_name)
CROSS JOIN generate_series(1,2000, 1) As i;

INSERT INTO public.observations(obs_name, obs_date, the_geom)
SELECT a.obs_name, DATE '2008-01-01'
+ CAST(CAST (random()*1000 As text) || ' days' As interval),
ST_SetSRID(
ST_Point(-100 + random()*30, 30 + random()*20),4326) As the_geom
FROM unnest(
ARRAY['dinoparrot', 'platibird', 'dove', 'pigeon',
'lizard monster', 'eagle', 'cat eater bird']) As a(obs_name)
CROSS JOIN generate_series(1,4000, 1) As i;

DELETE FROM public.observations
WHERE NOT EXISTS (SELECT s.gid FROM public.states AS s
WHERE ST_Intersects(s.the_geom,
ST_Transform(public.observations.the_geom,2163)) ) ;

---Tag data to a specific region
UPDATE public.observations
SET state = s.state, state_fips = s.state_fips
FROM public.states As s
WHERE ST_Intersects(s.the_geom,
ST_Transform(public.observations.the_geom,2163));

---Query to snap points to linestrings—version 1
SELECT pt_id, ln_id,
ST_Line_Interpolate_Point(ln_geom,
ST_Line_Locate_Point(ln_geom, pt_geom)
) As snapped_point
FROM
(SELECT DISTINCT ON (pt.gid)
ln.the_geom AS ln_geom,
pt.the_geom AS pt_geom, ln.gid AS ln_id, pt.gid AS pt_id
FROM
ch08.sites AS pt INNER JOIN
ch08.roads AS ln
ON
ST_DWithin(pt.the_geom, ln.the_geom, 10.0)
ORDER BY
pt.gid,ST_Distance(ln.the_geom, pt.the_geom)
) AS subquery;

---Query to snap points to linestring without subquery—version 2
SELECT DISTINCT ON (pt.id)
ln.the_geom AS ln_geom,
pt.the_geom AS pt_geom,
ln.id AS ln_id,
pt.id AS pt_id,
ST_Line_Interpolate_Point(
ln.the_geom,
ST_ClosestPoint(ln.the_geom, pt.the_geom)
) As snapped_point
FROM
point_table AS pt INNER JOIN
line_table AS ln
ON
ST_DWithin(pt.the_geom, ln.the_geom, 10.0)
ORDER BY
pt.id,ST_Distance(ln.the_geom, pt.the_geom);

---Geocoding an address to a point on a street
--Geocode an address to a point
CREATE TABLE sf.test_addresses(
gid SERIAL PRIMARY KEY,
st_num integer, 
st_name varchar(150), 
zipcode char(5),
st_pos char(1), 
the_geom geometry
);
INSERT INTO sf.test_addresses(st_num,st_name,zipcode)
VALUES
( 33, 'NEW MONTGOMERY ST', '94105' ),
( 250, 'CALIFORNIA AVE', '94130' ),
( 360, 'ROOSEVELT WAY', '94114' )
;
UPDATE sf.test_addresses
SET
st_pos = CASE WHEN MOD(sc.lf_fadd,2) =
MOD(sf.test_addresses.st_num,2)
THEN 'L'
ELSE 'R'
END,
the_geom = ST_Line_Interpolate_Point(
ST_LineMerge(sc.the_geom),
( sf.test_addresses.st_num - least(sc.lf_fadd, sc.rt_fadd) )
 / ( greatest (sc.lf_toadd, sc.rt_toadd) - least (sc.lf_fadd, sc.rt_fadd) )
)
FROM sf.stclines_streets AS sc
WHERE
substring(sc.zip_code,1,5) = sf.test_addresses.zipcode AND
sc.streetname = sf.test_addresses.st_name AND
(sf.test_addresses.st_num BETWEEN sc.lf_fadd AND sc.lf_toadd
OR sf.test_addresses.st_num BETWEEN sc.rt_fadd AND sc.rt_toadd);

---Divide the United States into quadrants.
WITH usext AS
(
SELECT ST_SetSRID(
CAST(ST_Extent(the_geom) As geometry),2163) As the_geom_ext,
60 as x_gridcnt, 40 as y_gridcnt
FROM us.states As s
),
grid_dim AS
(SELECT (
ST_XMax(the_geom_ext) - ST_XMin(the_geom_ext)
)/x_gridcnt As g_width,
ST_XMin(the_geom_ext) As xmin,
ST_xmax(the_geom_ext) As xmax,
(
ST_YMax(the_geom_ext) - ST_YMin(the_geom_ext)
)/y_gridcnt As g_height,
ST_YMin(the_geom_ext) As ymin,
ST_YMax(the_geom_ext) As ymax
FROM usext
),
grid As (
SELECT x,y,
ST_SetSRID(ST_MakeBox2d(
ST_Point(xmin + (x - 1)*g_width, ymin + (y-1)*g_height),
ST_Point(xmin + x*g_width, ymin + y*g_height)
)
,2163) As grid_geom
FROM (SELECT generate_series(1,x_gridcnt) FROM usext) As x(x)
CROSS JOIN (SELECT generate_series(1,y_gridcnt) FROM usext) As y(y)
CROSS JOIN grid_dim
)
SELECT grid.x, grid.y, state, state_fips,
ST_Intersection(s.the_geom, grid_geom) As the_geom
INTO us.grid_throwaway
FROM us.states As s
INNER JOIN grid
ON (ST_Intersects(s.the_geom, grid.grid_geom));
CREATE INDEX idx_us_grid_throwaway_the_geom
ON us.grid_throwaway USING gist(the_geom);

----Solving network routing problems with pgRouting
--Shortest route
ALTER TABLE twin_cities ADD COLUMN source integer;
ALTER TABLE twin_cities ADD COLUMN target integer;
ALTER TABLE twin_cities ADD COLUMN length double precision;

SELECT pgr_createTopology('nairobi_roads', 0.00001, 'geom', 'gid');
SELECT assign_vertex_id('twin_cities',.001,'the_geom','gid');

UPDATE twin_cities SET length = ST_Length(the_geom);

set search_path = public, ch10;
SELECT the_geom INTO ch10.dijkstra_result FROM dijkstra_sp('twin_cities',134,82);

--Traveling salesperson problem
CREATE TABLE spain_nuclear_plants
(id serial, plant_name character varying,
lat double precision, lon double precision);

SELECT vertex_id
FROM tsp('SELECT id as source_id, lon AS x, lat AS y FROM
spain_nuclear_plants','1,2,3,4,5,6,7',3);

---Graphing and accessing spatial analysis libraries with PL/R