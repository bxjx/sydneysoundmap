$(document).ready =>
  latlng = new google.maps.LatLng(-37.769629,144.961166)
  options =
    zoom: 11
    center: latlng
    mapTypeId: google.maps.MapTypeId.HYBRID
  map = new google.maps.Map(
    document.getElementById("map"),
    options
  )
