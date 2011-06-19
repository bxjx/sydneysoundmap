# todo: 
# * throttle - etag?
# * render js out
#
#
# configure, pull in what we need etc
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
      console.error("[soundcloud api error] #{e}")
      @checkAgain(10)
  checkAgain: (minutes) ->
    clearTimeout(@timeout) if @timeout
    timer = =>
      @check()
    @timeout = setTimeout timer, minutes * 60 * 1000

group = new SoundcloudContributions('28121', 'HAVZC0bHjrDNUbkqQSbqPg')
group.on 'change', (contributions) ->
  console.info("now have #{contributions.length}")

layout_template = """
!!! 5
html(lang="en")
  head
    title soundmapr
    link(rel='stylesheet', href='/style.css')
    script(src='/socket.io.js')
    script(src='http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js')
    script(src='http://maps.google.com/maps/api/js?sensor=false')
    script(type='text/javascript')
      var contributions = !{JSON.stringify(group.contributions)}
    script(src='/client.js')
  body(onunload='GUnload()')
    #map
"""
layout = jade.compile(layout_template)


app.get '/', (request, response) ->
  response.send(layout.call(this, {group}))
app.listen(port)
