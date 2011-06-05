(function() {
  var http, server;
  http = require('http');
  server = http.createServer(function(req, res) {
    res.writeHead(200, {
      'Content-Type': 'text/html'
    });
    return res.end('<h1>soundmapr!</h1>');
  });
  server.listen(8080);
}).call(this);
