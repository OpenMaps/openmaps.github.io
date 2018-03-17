<?php
/*
 *$username = 'openmaps_u';
 $password = '19@root#89';
 $database = 'openmaps_db';
 $server = '137.74.106.9';
 * */
 
# Connect to database
$conn = new PDO('pgsql:host=localhost;dbname=postgres','postgres','root');
# Build SQL SELECT statement and return the geometry as a GeoJSON element
$sql = 'SELECT *, public.ST_AsGeoJSON(public.ST_Transform((geom),4326),6) AS geojson FROM public.parcels';

# Try query or error
$rs = $conn->query($sql);
if (!$rs) {
    echo 'An SQL error occured.\n';
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
?>
