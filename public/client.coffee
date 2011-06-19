class Contribution extends Backbone.Model
  constructor: ->
    super
    @extractGeo()
  extractGeo: ->
    @tags = @get('tag_list').split(' ')
    ll_tag = _.detect @tags, (tag) ->
      /ll=/.exec(tag)
    if ll_tag and (tokens = /ll=(.*),(.*)/.exec(ll_tag))
      @ln = tokens[1]
      @lt = tokens[2]
      @location = new google.maps.LatLng(@ln, @lt)

class ContributionCollection extends Backbone.Collection
  model: Contribution

this.Contributions = new ContributionCollection()

this.soundManager.url = '/swf'
this.soundManager.useHTML5Audio = true

play = (marker) =>
  stream = marker.contribution.get('stream_url')
  this.soundManager.createSound
    id: 1111
    url: "#{stream}?client_id=HAVZC0bHjrDNUbkqQSbqPg"
    volume: 50
    autoPlay: true

$(document).ready =>
  latlng = new google.maps.LatLng(-33.868705,151.206894)
  options =
    zoom: 11
    center: latlng
    mapTypeId: google.maps.MapTypeId.ROADMAP
  map = new google.maps.Map(
    document.getElementById("map"),
    options
  )
  styles = [
    {
      featureType: "all"
      elementType: "all"
      stylers: [{saturation: -100 }] #, {visibility: "simplified"}]
    },
    {
      featureType: "road"
      elementType: "labels"
      stylers: [{visibility: "off"}]
    }
  ]
  styleOptions = {name: 'washedOut'}
  washedOutType = new google.maps.StyledMapType(styles, styleOptions)
  map.mapTypes.set(styleOptions['name'], washedOutType)
  map.setMapTypeId(styleOptions['name'])

  Contributions.refresh(contributions)
  popup = null
  Contributions.each (contribution) ->
    marker = new google.maps.Marker
      position: contribution.location
      map: map
      title: "#{contribution.get('title')} recorded by #{contribution.get('user').username}"
    marker.contribution = contribution
    google.maps.event.addListener marker, 'click', ->
      popup.close() if popup
      popup = new google.maps.InfoWindow
        content: "helllo: #{contribution.get('title')}"
        maxWidth: 640
      play(marker)
      popup.open(map, marker)

