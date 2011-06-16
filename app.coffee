express = require('express')
app = express.createServer(express.logger())
app.get '/', (request, response) ->
    response.send('soundmapr!')
port = 80 #process.env.PORT or 3000
console.log("Listening on #{port}")
app.listen(port)
