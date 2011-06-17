# configure, pull in what we need etc
https = require('https')
events = require('events')
jade = require('jade')
connect = require('connect')
express = require('express')
io = require('socket.io')
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


layout = '''
!!! 5
html(lang="en")
  head
    title soundmapr
    link(rel='stylesheet', href='/style.css')
    script(src='/socket.io.js')
    script(src='http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js')
    script(src='http://maps.google.com/maps/api/js?sensor=false')
    script(src='/client.js')
  body(onunload='GUnload()')
    #map
'''

app.get '/', (request, response) ->
  response.send(jade.render(layout))
app.listen(port)

group = new SoundcloudContributions('28121', 'HAVZC0bHjrDNUbkqQSbqPg')
sockets = io.listen(app)
sockets.on 'connection', (socket) ->
  socket.send(JSON.stringify(group.contributions))
group.on 'change', (contributions) ->
  sockets.broadcast(JSON.stringify(group.contributions))
