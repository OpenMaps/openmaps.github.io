---combine the siteaddres, city and zipcode columns into a single column
SELECT siteaddres || ' ' || city || ' ' || zipcode AS str
  FROM siteaddresses
  LIMIT 100;
---
---

-- Add a column for the text search data
ALTER TABLE siteaddresses ADD COLUMN ts tsvector;

-- Populate text search column by joining together relevant fields
-- into a single string
UPDATE siteaddresses
  SET ts  = to_tsvector('simple', siteaddres || ' ' || city || ' ' || zipcode)
  WHERE siteaddres IS NOT NULL;
  
  ---
  ---
  
  ---Let’s find all the records with “120 CINDY CT” in them
SELECT siteaddres, city
FROM siteaddresses
WHERE ts @@ to_tsquery('simple','120 & CINDY & CT');

---
---
---appending ”:*” to the text search query string to specify prefix matching for that word.
SELECT siteaddres, city
FROM siteaddresses
WHERE ts @@ to_tsquery('simple','120 & CI:*');

---include ranking function
---
SELECT
  siteaddres,
  city,
  ts_rank_cd(ts, query) AS rank
FROM siteaddresses,
     to_tsquery('simple','120 & CI:*') AS query
WHERE ts @@ query
ORDER BY rank DESC
LIMIT 10;

---combine columns
SELECT
  initcap(siteaddres || ', ' || city) AS address,
  ts_rank_cd(ts, query) AS rank
FROM siteaddresses,
     to_tsquery('simple','120 & CI:*') AS query
WHERE ts @@ query
ORDER BY rank DESC;

----
----

-- An SQL function to wrap up the pre-processing step that takes
-- an unformated query string and converts it to a tsquery for
-- use in the full-text search
CREATE OR REPLACE FUNCTION to_tsquery_partial(text)
  RETURNS tsquery AS $$
    SELECT to_tsquery('simple',
           array_to_string(
           regexp_split_to_array(
           trim($1),E'\\s+'),' & ') ||
           CASE WHEN $1 ~ ' $' THEN '' ELSE ':*' END)
  $$ LANGUAGE 'sql';

-- Input:  100 old high
-- Output: 100 & old & high:*
SELECT to_tsquery_partial('100 old high');

---
---Once we have a proper full-text search query string, we can plug it into a search query----
---
SELECT
  initcap(a.siteaddres || ', ' || city) AS address,
  a.id AS gid,
  ts_rank_cd(a.ts, query) AS rank
FROM siteaddresses AS a,
     to_tsquery_partial('100 old high') AS query
WHERE ts @@ query
ORDER BY rank DESC
LIMIT 10;


----try

    http://localhost:8080/geoserver/ows?service=WFS&version=2.0.0&request=GetFeature&typeName=couty:address_autocomplete&outputFormat=application/json&srsName=EPSG:3857&viewparams=query:100+old+high
    
---output
{
   "crs" : {
      "type" : "EPSG",
      "properties" : {
         "code" : "3857"
      }
   },
   "totalFeatures" : 1,
   "features" : [
      {
         "geometry_name" : "geom",
         "geometry" : {
            "coordinates" : [
               -13671227.5903573,
               5258470.52569557
            ],
            "type" : "Point"
         },
         "id" : "address_autocomplete.31410",
         "type" : "Feature",
         "properties" : {
            "address" : "100 Old Highway 62, Trail",
            "rank" : 0.1
         }
      }
   ],
   "type" : "FeatureCollection"
}
