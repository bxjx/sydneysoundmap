http = require('http')

server = http.createServer (req, res) ->
    res.writeHead(200, {'Content-Type': 'text/html'})
    res.end('<h1>soundmapr!</h1>')
server.listen(8080)
