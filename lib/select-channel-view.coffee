request = require 'request-promise'
{SelectListView} = require 'atom-space-pen-views'
PostView = require './post-view'


module.exports =

class SelectChannelView extends SelectListView
    # creates channels and users using the received token
    # then spawns a PostView that handles the post
    initialize: (token)->
        super

        @token = token
        @channels = []
        @users = []

        @addClass 'overlay from-top'
        @setItems @_createItems()
        @panel ?= atom.workspace.addModalPanel(item: @)
        @panel.show()
        @focusFilterEditor()

    viewForItem: (item) -> "<li>#{ item.name }</li>"

    getFilterKey: -> "name"

    confirmed: (item) -> new PostView item, @token

    cancelled: -> @panel.hide()

    # PRIVATE METHODS
    _createItems: ->
        @_getAllItems()
        items = []
        for i in [channels..., users...]
            [v, t] = if i.profile? then [i.profile.real_name, 'user'] else [i.name, 'channel']
            items.push({id:i.id, name:v, type:t})
        items

    _getAllItems: ->
      # loops till we have channels and users to post to,
      # then quits
      # needs improvement or better logic elsewhere, otherwise blocks
      # atom's loading for a bit too much
      if @channels.length == 0 and @users.length == 0
          console.log('fetching')
          @_getChannels()
          @_getUsers()
          setTimeout @_getAllItems.bind(@), 5 * 1000

    _getChannels: ->
      request({
          uri: 'https://slack.com/api/channels.list',
          qs: {'token': @token, 'exclude_archived': 1},
          json: true })
      .then( (body)=>
          if body['ok'] == false
              console.log(body['error'])
          else
              @channels = body['channels']
      )
      .catch( (err) => console.log(err) )

    _getUsers: ->
      request({
          uri: 'https://slack.com/api/users.list',
          qs: {'token': @token, 'deleted': false},
          json: true })
      .then( (body)=>
          if body['ok'] == false
              console.log(body['error'])
          else
              @users = body['members']
      )
      .catch( (err) => console.log(err) )
