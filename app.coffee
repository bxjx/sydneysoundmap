# todo: 
# * throttle - etag?
# configure, pull in what we need etc

# Go get what we need
https = require('https')
events = require('events')
jade = require('jade')
connect = require('connect')
express = require('express')
timers = require('timers')
app = express.createServer(
  express.logger(),
  connect.static("#{__dirname}/public")
)
app.set('view engine', 'jade')
port = process.env.PORT or 4000

# Checks soundcloud contributiions for group periodically
class SoundcloudContributions extends events.EventEmitter
  constructor: (@groupId, @clientId) ->
    @contributions = []
    @soundcloud =
      host: 'api.soundcloud.com'
      path: "/groups/#{@groupId}/tracks.json?client_id=#{@clientId}"
    @check()
  check: ->
    req = https.get @soundcloud, (res) =>
      results = ''
      res.on 'data', (data) ->
        results += data
      res.on 'end', =>
        num = @contributions.length
        @contributions = JSON.parse(results)
        @checkAgain(5)
        @emit('change', @contributions) if num != @contributions.length
    req.on 'error', (e) =>
      @emit('error', e)
      @checkAgain(30)
  checkAgain: (minutes) ->
    clearTimeout(@timeout) if @timeout
    timer = =>
      @check()
    @timeout = setTimeout timer, minutes * 60 * 1000

group = new SoundcloudContributions('28121', 'HAVZC0bHjrDNUbkqQSbqPg')
group.on 'change', (contributions) ->
  console.info("now have #{contributions.length}")
group.on 'error', (contributions) ->
  console.info("error while hitting service: #{e}")

layout_template = """
!!! 5
html(lang="en")
  head
    title Sydney Sound Map
    link(rel='stylesheet', href='/style.css')
    script(src='/underscore-min.js')
    script(src='/backbone.js')
    script(src='/soundmanager2-nodebug-jsmin.js')
    script(src='http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js')
    script(src='http://maps.google.com/maps/api/js?sensor=false')
    script(type='text/javascript')
      var contributions = !{JSON.stringify(group.contributions)}
    script(src='/client.js')
  body(onunload='GUnload()')
    #container
      #header
        h1 Sydney Sound Map
      #map
"""
layout = jade.compile(layout_template)

app.get '/', (request, response) ->
  response.send(layout.call(this, {group}))
app.listen(port)
