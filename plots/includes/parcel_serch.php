<?php
/*
 *$username = 'openmaps_u';
 $password = '19@root#89';
 $database = 'openmaps_db';
 $server = '137.74.106.9';
 * */
# Connect to postgreSQL database
$conn = new PDO('pgsql:host=localhost;dbname=postgres','postgres','root');
// Get parameters from URL
$searchstring = $_GET["searchstring"];
# Build SQL SELECT statement and return the geometry as a GeoJSON element
$parcel = "SELECT *, public.ST_AsGeoJSON(public.ST_Transform((geom),4326),6) AS geojson FROM public.parcels where parcels_no ilike '%$searchstring%'";

# Try query or error
$res = $conn->query($parcel);
if (!$res) {
    echo 'An SQL error occured.';
    exit;
}
# Build GeoJSON feature collection array
$geojson = array(
   'type'      => 'FeatureCollection',
   'features'  => array()
);
# Loop through rows to build feature arrays
while ($row = $res->fetch(PDO::FETCH_ASSOC)) {
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

?>
