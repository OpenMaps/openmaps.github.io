<?php
if (!empty($_GET['searchstring'])) {
# Connect to SQLite database
$conn = new PDO('pgsql:host=localhost;dbname=postgres','postgres','root');
// Get parameters from URL
$searchstring = $_GET["searchstring"];
# Build SQL SELECT statement and return the geometry as a GeoJSON element
$sql = "SELECT *, public.ST_AsGeoJSON(public.ST_Transform((geom),4326),6) AS geojson FROM public.protected where areaname ilike '%$searchstring%'";
/*
* If bbox variable is set, only return records that are within the bounding box
* bbox should be a string in the form of 'southwest_lng,southwest_lat,northeast_lng,northeast_lat'
* Leaflet: map.getBounds().toBBoxString()

if (isset($_GET['bbox'])) {
    $bbox = explode(',', $_GET['bbox']);
    $sql = $sql .'WHERE public.ST_Transform(geom, 4326) && public.ST_SetSRID(public.ST_MakeBox2D(public.ST_Point('.$bbox[0].', '.$bbox[1].'), public.ST_Point('.$bbox[2].', '.$bbox[3].')),4326);';
}*/
# Try query or error
$rs = $conn->query($sql);
#echo json_encode($rs, JSON_NUMERIC_CHECK);
if (!$rs) {
    echo 'An SQL error occured.';
    exit;
}
# Build GeoJSON feature collection array
$geojson = array(
   'type'      => 'FeatureCollection',
   'features'  => array()
);
# Loop through rows to build feature arrays
while ($row = $rs->fetch(PDO::FETCH_ASSOC)) {
    $properties = $row;
    # Remove geojson and geometry fields from properties
    unset($properties['geojson']);
    unset($properties['geom']);
    $feature = array(
         'type' => 'Feature',
         'geometry' => json_decode($row['geojson'], true),
         'properties' => $properties
    );
    # Add feature arrays to feature collection array
    array_push($geojson['features'], $feature);
}
header('Content-type: application/json');

echo json_encode($geojson, JSON_NUMERIC_CHECK);

$conn = NULL;
}
?>
