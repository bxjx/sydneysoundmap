express = require('express')
app = express.createServer(express.logger())
app.get '/', (request, response) ->
    response.send('soundmapr!')
port = process.env.PORT or 4000
console.log("Listening on #{port}")
app.listen(port)
