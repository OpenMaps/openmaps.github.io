<?php 
$page_title = 'The LIS | Securing Land for prosperity';
include ('./includes/header.html');
if(!$_SESSION['email'])  
{  
	header("Location: Login.php"); 
}
?>
<head>
	<style>
		.w3-navbar> li > a {padding: 13px 10px 11px;}
		.w3-navbar .btn, .w3-navbar .btn-group { margin-top: 8px;}
		.brand {font-size: 20px;font-family: serif; font-weight: bold;color: white;}
	</style>
	
</head>
<body class="w3-light-grey w3-content" style="max-width:100%">
    <div class="w3-container">
        <header class="w3-container w3-light-grey w3-round-large">
			<ul class="w3-navbar w3-black">
				<li><a class="brand" href="#">Land based Property<span style="color:green"> Co. Ltd </span> | Kenya</a></li>
				<!--<li><a class="brand" href="#" onclick="$('#infoModal').modal('show'); return false;"><i class="icon-question-sign icon-white"></i>More info</a></li>
				<li><a class="brand" href="#" onclick="$('#contactModal').modal('show'); return false;"><i class="icon-envelope icon-white"></i> Contact Us</a></li>
				-->
				<li><a class="brand" href="Logout.php" ><i class="icon-close-sign icon-white"></i> Logout</a></li>
				<!--
				<form class="navbar-form pull-right">
					<span style="padding-right: 20px;"><a class='btn btn-primary btn-small' data-toggle="modal" href="#addplotModal"><i class="icon-plus-sign icon-white"></i> Book Plot </a></span>
					</form>-->
            </ul>
       </header>
	</div>
<!--
<div class="modal hide fade" id="infoModal">
      <div class="modal-header">
        <a class="close" data-dismiss="modal">×</a>
        <h3>Welcome to the Leaflet Users Map!</h3>
      </div>
      <div class="modal-body">
        <h3>Inspiration</h3>
          <p>This project was inspired by the <a href="http://users.qgis.org/community-map/view_users.html" target="_blank">Quantum GIS Community Map</a>.</p>
        <h3>Leaflet</h3>
          <p>
            Leaflet is a modern, lightweight open-source JavaScript library for interactive maps by <a href="http://cloudmade.com/" target="_blank">CloudMade</a>. It has an <a href="https://github.com/CloudMade/Leaflet/contributors" target="_blank">active</a> group of contributors, which has generated a loyal <a href="https://github.com/CloudMade/Leaflet/issues/400" target="_blank">user</a> base and a lot of buzz in the community.
            <ul>
              <li><a href="http://leaflet.cloudmade.com/" target="_blank">Leaflet Homepage</a></li>
              <li><a href="http://github.com/CloudMade/Leaflet" target="_blank">GitHub Repo</a></li>
              <li><a href="https://groups.google.com/forum/?fromgroups#!forum/leaflet-js" target="_blank">Official Leaflet Support Community</a></li>
              <li><a href="http://leaflet.uservoice.com/" target="_blank">Ideas & Suggestions for Leaflet</a></li>
            </ul>
          </p>
        <h3>Mapping Leaflet Users</h3>
          <p>Leaflet users... on a Leaflet map! Built using the following components:
            <ul>
              <li>User Interface: <a href="http://twitter.github.com/bootstrap/" target="_blank">Bootstrap, from Twitter</a></li>
              <li>Mapping: <a href="http://leaflet.cloudmade.com/" target="_blank">Leaflet</a></li>
              <li>Database: <a href="http://www.sqlite.org/" target="_blank">SQLite</a></li>
              <li>Scripting: <a href="http://www.php.net/" target="_blank">PHP</a> & <a href="http://en.wikipedia.org/wiki/JavaScript" target="_blank">JavaScript</a></li>
            </ul>
          </p>
        <h3>Don't Blame Me</h3>
          <p>This site was hacked together by <a href="http://bryanmcbride.com/" target="_blank">Bryan McBride</a> in March 2012. I have no formal training in any of this and have likely broken many coding standards and best practices. Feel free to report any issues over at my <a href="https://github.com/bmcbride/leaflet-users-map">GitHub Repo</a>. Built with:
            <ul>
              <li><a href="http://www.adminer.org/" target="_blank">Adminer Database Management Tools</a></li>
              <li><a href="http://code.google.com/chrome/devtools/docs/overview.html" target="_blank">Chrome Developer Tools</a></li>
              <li><a href="http://www.sublimetext.com/2" target="_blank">Sublime Text 2</a></li>
            </ul>
          </p>
      </div>
    </div>
    -->
	<!-- Sidenav
	<div class="w3-container">
	<nav class="w3-sidenav w3-collapse w3-white w3-animate-left" style="z-index:5;width:20%; height:50%"><br>
			<div id="search">
				<ul class="w3-navbar w3-black">
					<li><a href="javascript:void(0)" onclick="openPage('Home')">Home</a></li>
					<li><a href="javascript:void(0)" onclick="openPage('Search')">Search</a></li>
				</ul></div>

				<div id="Home" class="w3-container page">
					<input type="text" id="searchInput" />
					<button class="w3-btn w3-white w3-border w3-border-red w3-round-large">Search</button></div>

				<div id="Search" class="w3-container page">
					<h2>Parcels</h2>
					<p>Which Parcels?</p></div>
	</nav>-->

	<div class="w3-main" style="margin-left:300px">
		<div class="w3-row-padding">
		  <div class="w3-container w3-white" id="map"></div>
		</div>
	</div>

  <!-- javascript
    ================================================== -->
  <!-- Placed at the end of the document so the pages load faster -->

<script type="text/javascript">
//base Layers			 
    var osm = new L.tileLayer("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      		subdomains: ["a","b","c"],
            attribution:'&copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors'});
			
	var esri = new L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
 			attribution: '&copy; <a href="http://www.esri.com/">Esri</a>, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP,and the GIS User Community'});
//variables         
	var map,parcels;	
 //Overlays functions  
	function styles(feature){
		return {weight: 2,opacity: 1,color: '#99C68E',dashArray: '3',fillOpacity: 0.7};}

	function highlightZoomFeature(e){
		var layer = e.target;
		map.fitBounds(e.target.getBounds());
		layer.setStyle({weight:2,color: '#666',dashArray: '1',fillOpacity: 0.0});}
		
	function mouseOut(e){
		var layer = e.target;
		layer.setStyle({weight:2,color: '#99C68E',dashArray: '1',fillOpacity: 0.3});}
	
	function onEachFeatures (feature,layer){
		//layer.on({mouseover: highlightZoomFeature,mouseout: mouseOut});
		//layer.on('click dblclick', function (){layer.bindPopup(feature.properties.f_r);});
		//layer.on('click',  onMapClick);$('#parcels').css('cursor', 'crosshair');return false;
		layer.on('click', onMapClick);
		}
//Map Overlays		
	parcels = new L.geoJson(null, {style: styles, onEachFeature: onEachFeatures});
	$.getJSON("postgis_polygon_geojson.php", function (data) {
		parcels.addData(data);}).complete(function () {
		map.fitBounds(parcels.getBounds([-1.2307,36.8114],[-1.1931,36.8940]));});

//Map object
	map = new L.Map('map',{ center: new L.latLng([-1.2096, 36.8562]),zoomControl : false,minZoom : 8,maxZoom : 18,layers: [osm, parcels]});
//bounding fix
	var southWest = new L.LatLng(-4.0177,26.6411);
	var northEast = new L.LatLng(4.3245,42.2974);
	var bounds = new L.LatLngBounds(southWest, northEast);
	map.setMaxBounds(bounds);  
//layers
	var baseLayers = {"OpenStreetMap": osm,"Esri Imagery": esri};
	var overlays = {"Parcels": parcels};
//controls
	L.control.zoom({position:'topright'}).addTo(map);
	layersControl = new L.Control.Layers(baseLayers, overlays,{collapsed: true, position: 'bottomright'	});
	map.addControl(layersControl);

/*leftbar		
	var sidebar = L.control.sidebar('sidebar-left');
	setTimeout(function () {sidebar.toggle();}, 500);
	setInterval(function () {sidebar.show();}, 5000);
	map.addControl(sidebar);
	
//infobar
openPage("Home")
function openPage(pageName) {
    var i;
    var x = document.getElementsByClassName("page");
    for (i = 0; i < x.length; i++) {
       x[i].style.display = "none";
    }
    document.getElementById(pageName).style.display = "block";
}*/
function updateParcels() {
        $("#loading-mask").show();
        $("#loading").show();
        var name = $("#name").val();
        var email = $("#email").val();
        var fon = $("#fon").val();
        var town = $("#tao").val();
        var bookt = $("#bookt").val();
        if (name.length == 0) {
          alert("Name is required!");
          return false;
        }
        if (email.length == 0) {
          alert("Email is required!");
          return false;
        }
        var dataString = 'name='+name +'&email='+email +'&phone='+fon +'&town='+town +'&bookt='+bookt;
        $.ajax({
          type: "POST",
          url: "update_parcels.php",
          data: dataString,
          success: function() {
            cancelRegistration();
            users.clearLayers();
            getUsers();
            $("#loading-mask").hide();
            $("#loading").hide();
            $('#updateSuccessModal').modal('show');
          }
        });
        return false;
      }
      
      function onMapClick(e) {
		var layer = e.target;
        var form =  
			  '<form id="inputform" enctype="multipart/form-data" class="well">'+
              '<label><strong>Name:</strong> <i>marker title</i></label>'+
              '<input type="text" class="span3" placeholder="Required" id="name" name="name" />'+
              '<label><strong>Email:</strong> <i>never shared</i></label>'+
              '<input type="text" class="span3" placeholder="Required" id="email" name="email" />'+
              '<label><strong>Phone:</strong></label>'+
              '<input type="text" class="span3" placeholder="Optional" id="fon" name="fon" />'+
              '<label><strong>Town:</strong></label>'+
              '<input type="text" class="span3" placeholder="Optional" id="tao" name="tao" />'+
              '<label><strong>Town:</strong></label>'+
              '<button type="display: none;" type="text" id="bookt" name="bookt" value="'+1+'" />'+
              '<div class="row-fluid">'+
                '<div class="span6" style="text-align:center;"><button type="button" class="btn" onclick="cancelBooking()">Cancel</button></div>'+
                '<div class="span6" style="text-align:center;"><button type="button" class="btn btn-primary" onclick="updateParcels()">Submit</button></div>'+
              '</div>'+
              '</form>';
       layer.bindPopup(form).openPopup();
      }
</script>
</body>
