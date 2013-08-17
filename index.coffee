express = require 'express'
http = require 'http'
ca = require 'connect-assets'
_s = require 'underscore.string'

app = express()
server = http.createServer app
io = require('socket.io').listen server

app.configure () ->
  app.set 'views', __dirname + '/app/views'
  app.set 'view engine', 'jade'
  app.use express.favicon __dirname + '/public/img/favicon.ico'
  app.use express.static __dirname + '/public'
  app.use ca {
    src: 'app/assets'
    buildDir: 'public'
  }

app.get '/', (req, res) ->
  res.render 'chat'

io.sockets.on 'connection', (socket) ->
  socket.on 'new', (data) ->
    socket.broadcast.emit 'message', {
      from: data.from
      content: _s.stripTags(_s.trim(data.content))
    }

server.listen 8080