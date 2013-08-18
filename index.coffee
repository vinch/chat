express = require 'express'
http = require 'http'
ca = require 'connect-assets'
_s = require 'underscore.string'

app = express()
server = http.createServer app
io = require('socket.io').listen server

safe = (str) ->
  return _s.escapeHTML(_s.trim(str))

app.configure () ->
  app.set 'views', __dirname + '/app/views'
  app.set 'view engine', 'jade'
  app.use express.favicon __dirname + '/public/img/favicon.ico'
  app.use express.static __dirname + '/public'
  app.use ca {
    src: 'app/assets'
    buildDir: 'public'
  }

io.configure ->
  io.set 'transports', ['xhr-polling']
  io.set 'polling duration', 10

io.sockets.on 'connection', (socket) ->
  socket.on 'message', (data) ->
    socket.broadcast.emit 'message', {
      from: safe data.from
      content: safe data.content
    }
  socket.on 'joined', (data) ->
    socket.broadcast.emit 'joined', {
      from: safe data.from
    }
  socket.on 'left', (data) ->
    console.log 'LEFT'
    socket.broadcast.emit 'left', {
      from: safe data.from
    }

app.get '/', (req, res) ->
  res.render 'chat'

server.listen process.env.PORT || 8080