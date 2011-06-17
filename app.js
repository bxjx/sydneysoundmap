(function() {
  var app, express, port;
  express = require('express');
  app = express.createServer(express.logger());
  app.get('/', function(request, response) {
    return response.send('soundmapr!');
  });
  port = process.env.PORT || 4000;
  console.log("Listening on " + port);
  app.listen(port);
}).call(this);
