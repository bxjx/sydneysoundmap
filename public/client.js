(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(document).ready(__bind(function() {
    var latlng, map, options;
    latlng = new google.maps.LatLng(-37.769629, 144.961166);
    options = {
      zoom: 11,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.HYBRID
    };
    return map = new google.maps.Map(document.getElementById("map"), options);
  }, this));
}).call(this);
