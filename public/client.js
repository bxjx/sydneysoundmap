(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(document).ready(__bind(function() {
    var latlng, map, options, socket;
    latlng = new google.maps.LatLng(-37.769629, 144.961166);
    options = {
      zoom: 11,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.HYBRID
    };
    map = new google.maps.Map(document.getElementById("map"), options);
    this.Contributions = [];
    socket = new io.Socket('localhost');
    socket.connect();
    return socket.on('message', __bind(function(data) {
      this.Contributions = JSON.parse(data);
      return console.log("got this many... " + this.Contributions.length);
    }, this));
  }, this));
}).call(this);
