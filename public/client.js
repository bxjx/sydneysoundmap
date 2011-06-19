(function() {
  var Contribution, ContributionCollection, play;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Contribution = (function() {
    __extends(Contribution, Backbone.Model);
    function Contribution() {
      Contribution.__super__.constructor.apply(this, arguments);
      this.extractGeo();
    }
    Contribution.prototype.extractGeo = function() {
      var ll_tag, tokens;
      this.tags = this.get('tag_list').split(' ');
      ll_tag = _.detect(this.tags, function(tag) {
        return /ll=/.exec(tag);
      });
      if (ll_tag && (tokens = /ll=(.*),(.*)/.exec(ll_tag))) {
        this.ln = tokens[1];
        this.lt = tokens[2];
        return this.location = new google.maps.LatLng(this.ln, this.lt);
      }
    };
    return Contribution;
  })();
  ContributionCollection = (function() {
    __extends(ContributionCollection, Backbone.Collection);
    function ContributionCollection() {
      ContributionCollection.__super__.constructor.apply(this, arguments);
    }
    ContributionCollection.prototype.model = Contribution;
    return ContributionCollection;
  })();
  this.Contributions = new ContributionCollection();
  this.soundManager.url = '/swf';
  this.soundManager.useHTML5Audio = true;
  play = __bind(function(marker) {
    var stream;
    stream = marker.contribution.get('stream_url');
    return this.soundManager.createSound({
      id: 1111,
      url: "" + stream + "?client_id=HAVZC0bHjrDNUbkqQSbqPg",
      volume: 50,
      autoPlay: true
    });
  }, this);
  $(document).ready(__bind(function() {
    var latlng, map, options, popup, styleOptions, styles, washedOutType;
    latlng = new google.maps.LatLng(-33.868705, 151.206894);
    options = {
      zoom: 11,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById("map"), options);
    styles = [
      {
        featureType: "all",
        elementType: "all",
        stylers: [
          {
            saturation: -100
          }
        ]
      }, {
        featureType: "road",
        elementType: "labels",
        stylers: [
          {
            visibility: "off"
          }
        ]
      }
    ];
    styleOptions = {
      name: 'washedOut'
    };
    washedOutType = new google.maps.StyledMapType(styles, styleOptions);
    map.mapTypes.set(styleOptions['name'], washedOutType);
    map.setMapTypeId(styleOptions['name']);
    Contributions.refresh(contributions);
    popup = null;
    return Contributions.each(function(contribution) {
      var marker;
      marker = new google.maps.Marker({
        position: contribution.location,
        map: map,
        title: "" + (contribution.get('title')) + " recorded by " + (contribution.get('user').username)
      });
      marker.contribution = contribution;
      return google.maps.event.addListener(marker, 'click', function() {
        if (popup) {
          popup.close();
        }
        popup = new google.maps.InfoWindow({
          content: "helllo: " + (contribution.get('title')),
          maxWidth: 640
        });
        play(marker);
        return popup.open(map, marker);
      });
    });
  }, this));
}).call(this);
