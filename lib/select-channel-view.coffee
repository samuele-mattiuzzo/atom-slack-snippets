request = require 'request-promise'
{SelectListView} = require 'atom-space-pen-views'
PostView = require './post-view'
MP = require './message-view'


module.exports =

class SelectChannelView extends SelectListView
    # creates channels and users using the received token
    # then spawns a PostView that handles the post
    initialize: (token)->
        super
        @mp = new MP()

        @token = token
        @channels = []
        @users = []
        @panel ?= atom.workspace.addModalPanel(item: @)

        @_create()

    viewForItem: (item) -> "<li>#{ item.name }</li>"

    getFilterKey: -> "name"

    confirmed: (item) ->
        @panel.hide()
        @view = new PostView item, @token

    cancelled: -> @panel.hide()

    destroy: ->
        @view = null
        @panel = null

    # PRIVATE METHODS
    _create: ->
        @_getChannels()

    _getChannels: ->
      request({
          uri: 'https://slack.com/api/channels.list',
          qs: {'token': @token, 'exclude_archived': 1},
          json: true })
      .then( (body)=>
          if body['ok'] == false
              # handle error message
              @_writeMessage body['error']
          else
              @channels = body['channels']
              @_getUsers()
      )
      .catch( (err) => console.log err )

    _getUsers: ->
      request({
          uri: 'https://slack.com/api/users.list',
          qs: {'token': @token, 'deleted': false},
          json: true })
      .then( (body)=>
          if body['ok'] == false
              # handle error message
              @_writeMessage body['error']
          else
              @users = body['members']
              @_drawAndSet()
      )
      .catch( (err) => console.log err )

    _drawAndSet:->
        items = []
        for i in [@channels..., @users...]
            [v, t] = if i.profile? then [i.profile.real_name, 'user'] else [i.name, 'channel']
            items.push {id:i.id, name:v, type:t}
        @setItems items

        @addClass 'overlay from-top'
        @panel ?= atom.workspace.addModalPanel(item: @)
        @panel.show()
        @focusFilterEditor()

    _writeMessage: (message) ->
        @panel.hide()
        @mp.setMessage(message)
        @panel.item = @mp.getElement()
        @panel.show()
