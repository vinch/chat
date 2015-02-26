# String

unless String::trim
  String::trim = ->
    @replace /^\s+|\s+$/g, ''

unless String::escapeHTML
  String::escapeHTML = ->
    @replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/'/, '&apos;').replace(/"/, '&quot;')

# Chat

window.Chat = {}

Chat.item = (content, classNames) ->
  $el = $('#conversation')
  $el.append('<li class="' + classNames.join(' ') + '">' + content + '</li>')
  $el.scrollTop $el[0].scrollHeight

Chat.message = (nickname, content) ->
  @item '<strong>' + nickname + '</strong>&nbsp;&#8212;&nbsp;' + content, ['message']

Chat.joined = (nickname) ->
  @item nickname + ' joined the room', ['notification']

Chat.left = (nickname) ->
  @item nickname + ' left the room', ['notification']

Chat.sendMessage = ->
  content = $('input').val()
  unless content == ''
    socket.emit 'message', {
      from: Chat.nickname
      content: content
    }
    Chat.message Chat.nickname.trim().escapeHTML(), content.trim().escapeHTML()
  $('input').val('')

$ ->
  FastClick.attach document.body

  if Modernizr.touch
    $('body').removeClass('no-touch')

  $.ajax {
    url: 'http://api.randomuser.me/'
    dataType: 'json'
    success: (data) ->
      Chat.nickname = data.results[0].user.username

      socket.emit 'joined', {
        from: Chat.nickname
      }
      Chat.joined 'You'

      $('#message').removeClass('disabled')
      $('input').focus()
  }

  window.socket = io.connect window.location.protocol + '//' + window.location.hostname + ':' + window.location.port

  # Events sent
  
  $(window).on 'resize', ->
    $el = $('#conversation')
    $el.scrollTop $el[0].scrollHeight

  $(window).on 'unload', ->
    socket.emit 'left', {
      from: Chat.nickname
    }

  $('input').keyup (e) ->
    if e.keyCode == 13
      Chat.sendMessage()

  $('button').click (e) ->
    Chat.sendMessage()

  # Events received

  socket.on 'message', (data) ->
    Chat.message data.from, data.content

  socket.on 'joined', (data) ->
    Chat.joined data.from

  socket.on 'left', (data) ->
    Chat.left data.fro