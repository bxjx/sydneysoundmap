(function() {
  var Contribution, ContributionCollection, info, play;
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
  info = function(contribution) {
    var artwork_url, content;
    artwork_url = contribution.get('artwork_url').replace("large", "t67x67");
    artwork_url = 'http://i1.sndcdn.com/artworks-000008395017-3hjvq3-t67x67.jpg?0e4c383';
    content = '<div class="info">';
    content += "<div class=\"artwork\" style=\"position:absolute; top: 0; left; 0;width:67px;height:67px;background-image: url(" + artwork_url + ")\"></div>";
    content += '<div class="metadata" style=\"margin-left: 80px;\">';
    content += "<a class=\"title\" href=\"" + (contribution.get('permalink_url')) + "\">" + (contribution.get('title')) + "</a><br />";
    content += "<strong>name: </strong><a class=\"username\" href=\"" + (contribution.get('user').permalink_url) + "\">" + (contribution.get('user').username) + "</a><br />";
    content += "<strong>location:</strong> House in Redfern<br />";
    content += '<strong>date:</strong> 20th June 2011<br />\n<strong>time of day:</strong> 0955<br />\n<strong>duration:</strong> 04:32<br />\n<strong>equipment used:</strong> laptop<br />\n<strong>description:</strong> Little fox being enjoying mush<br />\n<strong>license:</strong> Creative Commons Share Alike<br />';
    content += "<strong>tags:</strong> <a href=\"#\">human</a> <a href=\"#\">voice</a> <a href=\"#\">indoors</a>";
    content += '</div>';
    return content;
  };
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
          content: info(contribution),
          maxWidth: 640
        });
        play(marker);
        return popup.open(map, marker);
      });
    });
  }, this));
}).call(this);
