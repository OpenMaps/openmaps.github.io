function addr_search() {
  var inp = document.getElementById("addr");
//$.getJSON('http://nominatim.openstreetmap.org/search?format=json&limit=5&q='
  $.getJSON('serch.php?format=json&limit=5&q=' + inp.value, function(data) {
var items = [];

$.each(data, function(key, val) {
  items.push(
    "<li><a href='#' onclick='chooseAddr(" +
    val.lat + ", " + val.lon + ");return false;'>" + val.display_name +
    '</a></li>'
  );
});
$('#results').empty();
    if (items.length != 0) {
      $('<p>', { html: "Search results:" }).appendTo('#results');
      $('<ul/>', {
        'class': 'my-new-list',
        html: items.join('')
      }).appendTo('#results');
    } else {
      $('<p>', { html: "No results found" }).appendTo('#results');
    }
  });
}

function chooseAddr(lat, lng, type) {
  var location = new L.LatLng(lat, lng);
  map.panTo(location);

  if (type == 'city' || type == 'administrative') {
    map.setZoom(11);
  } else {
    map.setZoom(13);
  }
}
