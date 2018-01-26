//global variables
var map; //map object
var hData; //array of objects

var markersLayer; //markers layer group object

var timestamp = 2010; //initial timestamp
var scaleFactor = 25; //scale factor for marker area

var timer; //timer object for animation
var timerInterval = 1000; //initial animation speed in milliseconds


//begin script when window loads 
window.onload = initialize();

//the first function called once the html is loaded
function initialize(){
	//window.onload
	setMap();
};

//set basemap parameters
function setMap() {
	//initialize()
	
	//create the map and set its initial view
        map = new L.Map('map',{scrollWheelZoom:false,minZoom: 12,maxZoom: 14}).setView([-1.28141,36.83111], 13);
	
	//add the tile layer to the map
	var layer = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',
		{attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
		}).addTo(map);
		
	//call the function to process the csv with the data
	processCSV();
};

function processCSV() {
	//setMap()

	//process the healthData csv file
	var processCSV = new ProcessCSV(); // to ProcessCSV.js
	var csv = './d/health.csv'; // set location of csv file

	processCSV.addListener("complete", function(){
		hData = processCSV.getCSV(); // to ProcessCSV.js; returns array object
		createMarkers(); //->
                console.log(hData);
	});
	
	processCSV.process(csv); //-> to ProcessCSV.js
};

function createMarkers() {
	//processCSV()
	//radius of markers
	var radius = 10;

	//marker style object
	var markerStyle = {
		radius: radius,
		fillColor: "#29F",
	};

	//create array to hold markers
	var markersArray = [];
		
	//create a circle marker for each feature object in the csvData array
	for (var i=0; i<hData.length; i++) {
		var feature = {};
		feature.properties = hData[i];
		var lat = Number(feature.properties.latitude);
		var lng = Number(feature.properties.longitude);
		var marker = L.circleMarker([lat,lng], markerStyle);
		marker.feature = feature;
		markersArray.push(marker);
	};
	
	//create a markers layer with all of the circle markers
	markersLayer = L.featureGroup(markersArray);
	
	//add the markers layer to the map
	markersLayer.addTo(map);
	
	//call the function to size each marker and add its popup
	markersLayer.eachLayer(function(layer) {
		onEachFeature(layer);//->
	})
	
	animateMap();//->
}

function onEachFeature(layer) {
	//<-createMarkers()
	
	//calculate the area based on the data for that timestamp
	var area = layer.feature.properties[timestamp] * scaleFactor;
	
	//calculate the radius
	var radius = Math.sqrt(area/Math.PI);
	
	//set the symbol radius
	layer.setRadius(radius);
        
        //create and style the HTML in the information popup
	var popupHTML = "<b>" + layer.feature.properties[timestamp] + 
                        " visits</b><br>" + "<i> " + layer.feature.properties.name + 
                        "</i> in <i>" + timestamp + "</i>";
                        
	//bind the popup to the feature
	layer.bindPopup(popupHTML, {
		offset: new L.Point(0,-radius)
	});
	
	//information popup on hover
	layer.on({
		mouseover: function(){
			layer.openPopup();
			this.setStyle({radius: radius, color: 'yellow'});
		},
		mouseout: function(){
			layer.closePopup();
			this.setStyle({color: 'blue'});
		}
	});
}

function animateMap() {
	//<-setMap();
	
	timer = setInterval(function(){
		step();//->
	},timerInterval);
}

function step(){
	//<-animateMap()
	
	//cycle through years
	if (timestamp < 2016){ //update with last timestamp header
		timestamp++;
	} else {
		timestamp = 2010; //update with first timestampe header
	};
	
	//upon changing the timestamp, call onEachFeature to update the display
	markersLayer.eachLayer(function(layer) {
		onEachFeature(layer);//->
	});
}


/*
var map;
map = new L.Map('map',{scrollWheelZoom:false,minZoom: 12,maxZoom: 16}).setView([-1.2641,36.7494], 13);
 
//TMS layer
L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

//Add custom icon

var MyIcon = L.icon({
iconUrl: 'http://localhost/svg/flame.svg',
iconSize: [20, 20], // size of the icon
popupAnchor: [0,-15]
});

//Custom popup

var customPopup = "Nairobi<br/><img src='http://localhost/svg/dribble_gif.gif' alt='dribble_gif gif'width='350px'/>";
var customOptions ={
    'maxWidth': '500',
    'className' : 'custom'
}
L.marker([-1.2641,36.7494], {icon: MyIcon}).bindPopup(customPopup,customOptions).addTo(map);
*/


/*
var hc = {
"type": "FeatureCollection",
"features": [
{ "type": "Feature", "properties": { "id": 1, "name": "BAHATI DISP", "latitude": -1.29221, "longitude": 36.8621, "2005": 85, "2006": 38, "2007": 75, "2008": 30, "2009": 9, "2010": 15, "2011": 38 }, "geometry": { "type": "Point", "coordinates": [ 36.8621, -1.29221 ] } },
{ "type": "Feature", "properties": { "id": 2, "name": "BORAH ROAD DISP", "latitude": -1.27123, "longitude": 36.83112, "2005": 28, "2006": 29, "2007": 38, "2008": 26, "2009": 15, "2010": 12, "2011": 10 }, "geometry": { "type": "Point", "coordinates": [ 36.83112, -1.27123 ] } },
{ "type": "Feature", "properties": { "id": 3, "name": "CATHOLIC DISP", "latitude": -1.26341, "longitude": 36.84111, "2005": 18, "2006": 59, "2007": 22, "2008": 60, "2009": 82, "2010": 42, "2011": 18 }, "geometry": { "type": "Point", "coordinates": [ 36.84111, -1.26341 ] } },
{ "type": "Feature", "properties": { "id": 4, "name": "DANDORA HEALTH CENTRE", "latitude": -1.25761, "longitude": 36.88775, "2005": 35, "2006": 45, "2007": 31, "2008": 26, "2009": 14, "2010": 9, "2011": 15 }, "geometry": { "type": "Point", "coordinates": [ 36.88775, -1.25761 ] } },
{ "type": "Feature", "properties": { "id": 5, "name": "EMBAKASI DISP", "latitude": -1.30795, "longitude": 36.91262, "2005": 12, "2006": 31, "2007": 15, "2008": 22, "2009": 28, "2010": 38, "2011": 31 }, "geometry": { "type": "Point", "coordinates": [ 36.91262, -1.30795 ] } },
{ "type": "Feature", "properties": { "id": 6, "name": "CRESENT MEDICAL AID", "latitude": -1.28141, "longitude": 36.83111, "2005": 25, "2006": 50, "2007": 25, "2008": 25, "2009": 25, "2010": 25, "2011": 100 }, "geometry": { "type": "Point", "coordinates": [ 36.83111, -1.28141 ] } },
{ "type": "Feature", "properties": { "id": 7, "name": "HONO CRESCENT", "latitude": -1.28773, "longitude": 36.85865, "2005": 88, "2006": 46, "2007": 56, "2008": 15, "2009": 12, "2010": 25, "2011": 46 }, "geometry": { "type": "Point", "coordinates": [ 36.85865, -1.28773 ] } },
{ "type": "Feature", "properties": { "id": 8, "name": "JERICHO HEALTH CENTRE", "latitude": -1.28896, "longitude": 36.87117, "2005": 52, "2006": 51, "2007": 46, "2008": 68, "2009": 75, "2010": 85, "2011": 96 }, "geometry": { "type": "Point", "coordinates": [ 36.87117, -1.28896 ] } },
{ "type": "Feature", "properties": { "id": 9, "name": "HURUMA LIONS CLINIC", "latitude": -1.26111, "longitude": 36.85214, "2005": 7, "2006": 12, "2007": 18, "2008": 11, "2009": 9, "2010": 9, "2011": 4 }, "geometry": { "type": "Point", "coordinates": [ 36.85214, -1.26111 ] } },
{ "type": "Feature", "properties": { "id": 10, "name": "KALOLENI", "latitude": -1.29282, "longitude": 36.84534, "2005": 23, "2006": 18, "2007": 16, "2008": 24, "2009": 26, "2010": 28, "2011": 30 }, "geometry": { "type": "Point", "coordinates": [ 36.84534, -1.29282 ] } },
{ "type": "Feature", "properties": { "id": 11, "name": "KANGEMI HEALTH CENTRE", "latitude": -1.26461, "longitude": 36.74933, "2005": 32, "2006": 28, "2007": 29, "2008": 25, "2009": 22, "2010": 15, "2011": 8 }, "geometry": { "type": "Point", "coordinates": [ 36.74933, -1.26461 ] } },
{ "type": "Feature", "properties": { "id": 12, "name": "KASARANI", "latitude": -1.21821, "longitude": 36.90139, "2005": 8, "2006": 15, "2007": 22, "2008": 25, "2009": 29, "2010": 28, "2011": 32 }, "geometry": { "type": "Point", "coordinates": [ 36.90139, -1.21821 ] } },
{ "type": "Feature", "properties": { "id": 13, "name": "MAKADARA", "latitude": -1.29431, "longitude": 36.87226, "2005": 82, "2006": 74, "2007": 72, "2008": 10, "2009": 85, "2010": 88, "2011": 74 }, "geometry": { "type": "Point", "coordinates": [ 36.87226, -1.29431 ] } },
{ "type": "Feature", "properties": { "id": 14, "name": "MUTHURWA DISP", "latitude": -1.2834, "longitude": 36.8332, "2005": 9, "2006": 16, "2007": 14, "2008": 23, "2009": 45, "2010": 66, "2011": 85 }, "geometry": { "type": "Point", "coordinates": [ 36.8332, -1.2834 ] } },
{ "type": "Feature", "properties": { "id": 15, "name": "NGARA HEALTH CENTRE", "latitude": -1.27077, "longitude": 36.83046, "2005": 33, "2006": 45, "2007": 68, "2008": 96, "2009": 102, "2010": 82, "2011": 74 }, "geometry": { "type": "Point", "coordinates": [ 36.83046, -1.27077 ] } }
]
},

var hcpoints = L.geoJson(hc, {
	pointToLayer: function (feature, latlng) {
	return L.marker(latlng, hcsymbol);
	}
}).addTo(map);

*/