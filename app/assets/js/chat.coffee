# String

unless String::trim
  String::trim = ->
    @replace /^\s+|\s+$/g, ''

unless String::escapeHTML
  String::escapeHTML = ->
    @replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/'/, '&apos;').replace(/"/, '&quot;')

# Chat

window.Chat = {}

Chat.displayMessage = (from, content) ->
  $el = $('#conversation')
  $el.append('<li><strong>' + from + ' </strong> · ' + content + '</li>')
  $el.scrollTop $el[0].scrollHeight

$ ->
  loop
    Chat.from = prompt('What\'s your nickname?')
    break if Chat.from

  socket = io.connect 'http://192.168.1.22:8080'

  $('input').focus().keyup (e) ->
    if e.keyCode == 13
      content = $(this).val()
      unless content == ''
        socket.emit 'new', {
          from: Chat.from
          content: content
        }
        Chat.displayMessage Chat.from, content.trim().escapeHTML() # this is done on the server as well FYI
      $(this).val('')

  socket.on 'message', (data) ->
    Chat.displayMessage data.from, data.content