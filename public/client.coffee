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

info = (contribution) ->
  artwork_url = contribution.get('artwork_url').replace("large", "t67x67")
  artwork_url = 'http://i1.sndcdn.com/artworks-000008395017-3hjvq3-t67x67.jpg?0e4c383'
  content = '<div class="info">'
  content += "<div class=\"artwork\" style=\"position:absolute; top: 0; left; 0;width:67px;height:67px;background-image: url(#{artwork_url})\"></div>"
  content += '<div class="metadata" style=\"margin-left: 80px;\">'
  content += "<a class=\"title\" href=\"#{contribution.get('permalink_url')}\">#{contribution.get('title')}</a><br />"
  content += "<strong>name: </strong><a class=\"username\" href=\"#{contribution.get('user').permalink_url}\">#{contribution.get('user').username}</a><br />"
  #content += "#{contribution.get('tag_list')}"
  content += "<strong>location:</strong> House in Redfern<br />"
  content += '''
  <strong>date:</strong> 20th June 2011<br />
  <strong>time of day:</strong> 0955<br />
  <strong>duration:</strong> 04:32<br />
  <strong>equipment used:</strong> laptop<br />
  <strong>description:</strong> Little fox being enjoying mush<br />
  <strong>license:</strong> Creative Commons Share Alike<br />
  '''
  content += "<strong>tags:</strong> <a href=\"#\">human</a> <a href=\"#\">voice</a> <a href=\"#\">indoors</a>"
  content += '</div>'
  content

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
        content: info(contribution)
        maxWidth: 640
      play(marker)
      popup.open(map, marker)

