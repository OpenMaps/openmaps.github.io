//map initialization
/*
var map = new L.Map('map', { center: new L.LatLng(-1.2641,36.7494),zoom: 13,minZoom: 12,maxZoom: 16});
*/
var map = new L.Map('map',{scrollWheelZoom:false}).setView([-1.2641,36.7494], 13);
 
//TMS layer
L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

//Add custom icon

var MyIcon = L.icon({
iconUrl: 'https://openmaps.github.io/tutor/svg/flame.svg',
iconSize: [20, 20], // size of the icon
popupAnchor: [0,-15]
});

//Add interaction: popup 
/*
var marker = L.marker([-1.2641,36.7494], {icon: MyIcon}).addTo(map);
https://github.com/OpenMaps/tutor/blob/master/svg/dribble_gif.gif

L.marker([-1.2641,36.7494], {icon: MyIcon}).bindPopup('Nairobi').addTo(map);
*/
//Custom popup

var customPopup = "Nairobi<br/><img src='https://openmaps.github.io/tutor/svg/dribble_gif.gif' alt='dribble_gif gif'width='350px'/>";
var customOptions ={
    'maxWidth': '500',
    'className' : 'custom'
}
L.marker([-1.2641,36.7494], {icon: MyIcon}).bindPopup(customPopup,customOptions).addTo(map);


/*
var schools = {
"type": "FeatureCollection",
"features": [{ "type": "Feature",
"properties": { "name": "Chianina" },
"geometry": { "type": "Point", "coordinates": [ -1.2641,36.7494 ] }
},

var schoolpoints = L.geoJson(schools, {
	pointToLayer: function (feature, latlng) {
	return L.marker(latlng, MyIcon);
	}
}).addTo(map);
*/
//Geolocation
map.locate({setView: true, maxZoom: 16});

function onLocationFound(e) {
    var radius = e.accuracy / 2;
    L.marker(e.latlng).addTo(map).bindPopup("You are within " + radius + " meters from this point").openPopup();
    L.circle(e.latlng, radius).addTo(map);
}

map.on('locationfound', onLocationFound);

function onLocationError(e) {
    alert(e.message);
}

map.on('locationerror', onLocationError);

/*
function showCoords(e) {
	popup
		.setLatLng(e.latlng)
		.setContent(e.latlng.toString())
		.openOn(map);
}
map.on('click', showCoords);
*/
