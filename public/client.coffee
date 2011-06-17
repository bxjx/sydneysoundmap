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
  this.Contributions = []
  socket = new io.Socket('localhost')
  socket.connect()
  socket.on 'message', (data) =>
    this.Contributions = JSON.parse(data)
    console.log("got this many... " +  this.Contributions.length)
