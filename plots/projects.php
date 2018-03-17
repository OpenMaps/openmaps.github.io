<?php 
$page_title = 'The LIS | Securing Land for prosperity';
include ('./includes/header.html');

?>
<body>
<p class="topper"><span style="color:red">Open</span>Maps<span style="color:green"> Co.</span> | Kenya

 <a class="logo" href="Logout.php"><strong>Logout</strong></a>
 </p>	
	<div id="map" >
	</div>
	<div id="sidebar-left" >
		<div id="search">
				<div id="Tabs">
					<ul>
							<li id="li_tab1" onclick="tab('tab1')"><a>Office to Parcels</a></li>
							<li id="li_tab2" onclick="tab('tab2')"><a>Queries</a></li>
					</ul>
					<div id="Content_Area">
						<div id="tab1"></div>
						
						<div id="tab2" style="display: none;">
							<div id="rcorners2"></div>
							<div id="rcorners1"></div>
						</div>
				</div> 
			</div>
		</div>
	</div>
<script type="text/javascript">
	function tab(tab) {
		document.getElementById('tab1').style.display = 'none';
		document.getElementById('tab2').style.display = 'none';
		document.getElementById('li_tab1').setAttribute("class", "");
		document.getElementById('li_tab2').setAttribute("class", "");
		document.getElementById(tab).style.display = 'block';
		document.getElementById('li_'+tab).setAttribute("class", "active");
	}

	//base Layers			    
    var osm = new L.tileLayer("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      		subdomains: ["a","b","c"],
			attribution:'&copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors'
	});
			
	var esri = new L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
 				attribution: '&copy; <a href="http://www.esri.com/">Esri</a>, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP,and the GIS User Community'
 	});
 	var googleLayer = googleStreets = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
		maxZoom: 14,
		subdomains:['mt0','mt1','mt2','mt3']
	});
	/*
	change the "lyrs" parameter in the URL:
	Hybrid: s,h;
	Satellite: s;
	Streets: m;
	Terrain: p;
	*/
 	
    /*functions & variables*/
        var map, parcels;	
		/*color scheme*/
		function getColor(d) {
			return d > 5.0 ? '#800026' :
				   d > 4.0 ? '#BD0026' :
				   d > 3.0 ? '#E31A1C' :
				   d > 2.0 ? '#FC4E2A' :
				   d > 1.0 ? '#FD8D3C' :
				   d > 0.5 ? '#FEB24C' :
				   d > 0.1 ? '#FED976' :
                             '#FFEDA0' ;
		};
		
		var highlightStyle = {
			color: '#2262CC', 
			weight: 3,
			opacity: 0.6,
			fillOpacity: 0.65,
			fillColor: '#99C68E'
		};
		function styles(feature){
                    return {
                        weight: 1,
                        opacity: 0.8,
                        color: '#99C68E',
                        dashArray: '3',
                        fillOpacity: 0.7,
                        fillColor: getColor(feature.properties.area_ha)
                    };
		}
		
		function highlightFeature(e){
                    var layer = e.target;
                    layer.setStyle({
                        weight:2,
                        color: '#666',
                        dashArray: '',
                        fillOpacity: 0.7
                    });
      
		}
		
		function zoomToFeature(e){
                    map.fitBounds(e.target.getBounds());
        }
        function onFeature(e) {
			var onclck = e.target.feature.properties.lr_no;
			
			  $.ajax({
				url: './includes/search_results_json.php?lr_no=' + onclck,
				type: 'GET',
				dataType: 'JSON',
				success: function response(data) {
					$("#rcorners2").html(data);
					console.log(data);
				}	
			  });
		}
                
		function onEachFeatures (feature,layer){
			layer.on({
				mouseover: highlightFeature,
				click: zoomToFeature,
				dblclick: onFeature
			});
		}
		
				
		//Overlays from postgres database
		parcels = new L.geoJson(null, {
                    style: styles,
                    onEachFeature: onEachFeatures
		});
		$.getJSON("postgis_polygon_geojson.php", function (data) {
			parcels.addData(data);
		}).complete(function () {
			map.fitBounds(parcels.getBounds([-1.2307,36.8114],[-1.1931,36.8940]));
		});
		
										
		//Map object
		map = new L.Map('map',{ 
			center: new L.latLng([-1.2096, 36.8562]),
			//center: new L.latLng([0.138595, 32.575298]),
			zoomControl : false,
			minZoom : 8,
			maxZoom : 18,
			layers: [osm, parcels]
		});
		
		var baseLayers = {
      		"OpenStreetMap": osm,
      		"Esri Imagery": esri,
      		"Google Roads": googleLayer
		};
		var overlays = {
			"Parcels": parcels
		};
		
		L.control.zoom({position:'topright'}).addTo(map);
			
		layersControl = new L.Control.Layers(baseLayers, overlays,{collapsed: true, position: 'bottomright'	});
		map.addControl(layersControl);

//leftbar		
		var sidebar = L.control.sidebar('sidebar-left');
		
		setTimeout(function () {
            sidebar.toggle();
        }, 500);
		
        setInterval(function () {
            sidebar.show();
        }, 5000);
	
		map.addControl(sidebar);
		
//bounding fix
        var southWest = new L.LatLng(-4.0177,26.6411);
		var northEast = new L.LatLng(4.3245,42.2974);
		var bounds = new L.LatLngBounds(southWest, northEast);
		map.setMaxBounds(bounds);
		
//search osm
	map.addControl( new L.Control.Search({
		url: 'http://nominatim.openstreetmap.org/search?format=json&q={s}',
		jsonpParam: 'json_callback',
		propertyName: 'display_name',
		propertyLoc: ['lat','lon']
	}));
		
	var drawnItems = new L.FeatureGroup();	
	map.addLayer(drawnItems);

	var style = {color:'green', opacity: 1.0, fillOpacity: 0.8, weight: 1, clickable: true};
	
/*End of javascript	*/
</script>
