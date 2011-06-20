(function() {
  var SoundcloudContributions, app, connect, events, express, group, https, jade, layout, layout_template, port, timers;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  https = require('https');
  events = require('events');
  jade = require('jade');
  connect = require('connect');
  express = require('express');
  timers = require('timers');
  app = express.createServer(express.logger(), connect.static("" + __dirname + "/public"));
  app.set('view engine', 'jade');
  port = process.env.PORT || 4000;
  SoundcloudContributions = (function() {
    __extends(SoundcloudContributions, events.EventEmitter);
    function SoundcloudContributions(groupId, clientId) {
      this.groupId = groupId;
      this.clientId = clientId;
      this.contributions = [];
      this.soundcloud = {
        host: 'api.soundcloud.com',
        path: "/groups/" + this.groupId + "/tracks.json?client_id=" + this.clientId
      };
      this.check();
    }
    SoundcloudContributions.prototype.check = function() {
      var req;
      req = https.get(this.soundcloud, __bind(function(res) {
        var results;
        results = '';
        res.on('data', function(data) {
          return results += data;
        });
        return res.on('end', __bind(function() {
          var num;
          num = this.contributions.length;
          this.contributions = JSON.parse(results);
          this.checkAgain(5);
          if (num !== this.contributions.length) {
            return this.emit('change', this.contributions);
          }
        }, this));
      }, this));
      return req.on('error', __bind(function(e) {
        this.emit('error', e);
        return this.checkAgain(30);
      }, this));
    };
    SoundcloudContributions.prototype.checkAgain = function(minutes) {
      var timer;
      if (this.timeout) {
        clearTimeout(this.timeout);
      }
      timer = __bind(function() {
        return this.check();
      }, this);
      return this.timeout = setTimeout(timer, minutes * 60 * 1000);
    };
    return SoundcloudContributions;
  })();
  group = new SoundcloudContributions('28121', 'HAVZC0bHjrDNUbkqQSbqPg');
  group.on('change', function(contributions) {
    return console.info("now have " + contributions.length);
  });
  group.on('error', function(contributions) {
    return console.info("error while hitting service: " + e);
  });
  layout_template = "!!! 5\nhtml(lang=\"en\")\n  head\n    title Sydney Sound Map\n    link(rel='stylesheet', href='/style.css')\n    script(src='/underscore-min.js')\n    script(src='/backbone.js')\n    script(src='/soundmanager2-nodebug-jsmin.js')\n    script(src='http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js')\n    script(src='http://maps.google.com/maps/api/js?sensor=false')\n    script(type='text/javascript')\n      var contributions = !{JSON.stringify(group.contributions)}\n    script(src='/client.js')\n  body(onunload='GUnload()')\n    #container\n      #header\n        h1 Sydney Sound Map\n      #map";
  layout = jade.compile(layout_template);
  app.get('/', function(request, response) {
    return response.send(layout.call(this, {
      group: group
    }));
  });
  app.listen(port);
}).call(this);
