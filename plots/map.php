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
				<li><a class="brand" href="Logout.php" ><i class="icon-close-sign icon-white"></i> Logout</a></li>
            </ul>
       </header>
	</div>
	<div class="w3-main" style="margin-left:300px">
		<div class="w3-row-padding">
		  <div class="w3-container w3-white" id="map"></div>
		</div>
	</div>
	
	<div class="modal hide fade" id="updateSuccessModal">
      <div class="modal-header">
        <a class="close" data-dismiss="modal">×</a>
        <h3>Success!</h3>
      </div>
      <div class="modal-body">
        <p>Thanks for booking!</p>
        <p>You should receive an email shortly for confirmation.</p>
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
	
	var googleLayer = new L.Google('TERRAIN');
//variables         
	var map,parcels;	

//Overlays functions  
	function styles(feature){
		return {weight: 2,opacity: 1,color: '#99C68E',dashArray: '3',fillOpacity: 0.7};
	}

	function highlightZoomFeature(e){
		var layer = e.target;
		map.fitBounds(e.target.getBounds());
		layer.setStyle({weight:2,color: '#666',dashArray: '1',fillOpacity: 0.0});
	}
	
	function highlight(e){
		var layer = e.target;
		if(layer.feature.properties.TOKEN != ''){
			layer.setStyle({fillColor:'red'})
		};
	}
	
	function mouseOut(e){
		var layer = e.target;
		layer.setStyle({weight:2,color: '#99C68E',dashArray: '1',fillOpacity: 0.3});
	}
	
	function onEachFeatures (feature,layer){
		layer.on('click',  onMapClick);$('#parcels').css('cursor', 'crosshair');return false;
		
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
	var baseLayers = {"OpenStreetMap": osm,"Esri Imagery": esri, "Google Maps": googleLayer};
	var overlays = {"MyMap": parcels};

//controls
	L.control.zoom({position:'topright'}).addTo(map);
	layersControl = new L.Control.Layers(baseLayers, overlays,{collapsed: true, position: 'bottomright'	});
	map.addControl(layersControl);

	function insertUser() {
        $("#loading-mask").show();
        $("#loading").show();
        var name = $("#name").val();
        var email = $("#email").val();
        var phone = $("#phone").val();
        var token = $("#token").val();
        var lat = $("#lat").val();
        var lng = $("#lng").val();
        if (name.length == 0) {
          alert("Name is required!");
          return false;
        }
        if (email.length == 0) {
          alert("Email is required!");
          return false;
        }
        if (token.length == 0){
			alert("Paybill is required!");
			return false;
		}
		
        var dataString = 'name='+name +'&email='+email +'&phone='+phone +'&token='+token  + '&lat=' + lat + '&lng=' + lng;
        $.ajax({
          type: "POST",
          url: "insert.php",
          data: dataString,
          success: function() {
            highlight;
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
			  '<form id="inputform" enctype="multipart/form-data" class="form-inline" role="form"'+
				  '<label><strong>Name:</strong> </label>'+
				  '<input type="text" class="w3-input w3-border w3-round" placeholder="Required" id="name" name="name" />'+
				  '<label><strong>Email:</strong> </label>'+
				  '<input type="text" class="w3-input w3-border w3-round" placeholder="Required" id="email" name="email" />'+
				  '<label><strong>Phone:</strong></label>'+
				  '<input type="text" class="w3-input w3-border w3-round" placeholder="Optional" id="fon" name="fon" />'+
				  '<label><strong>Paybill Token:</strong></label>'+
				  '<input type="text" class="w3-input w3-border w3-round" placeholder="Required" id="token" name="token" />'+
				  '<input style="display: none;" type="text" id="lat" name="lat" value="'+e.latlng.lat.toFixed(6)+'" />'+
				  '<input style="display: none;" type="text" id="lng" name="lng" value="'+e.latlng.lng.toFixed(6)+'" /><br><br>'+
			
				  '<div class="row-fluid">'+
					    '<div class="form-horizontal" style="text-align:center;"><button type="button" class="btn btn-primary" onclick="insertUser()">Submit</button></div>'+
				  '</div>'+
              '</form>';
       layer.bindPopup(form).openPopup();
      }
</script>
</body>
