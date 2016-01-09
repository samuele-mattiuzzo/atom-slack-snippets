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

        @_create()


    viewForItem: (item) -> "<li>#{ item.name }</li>"

    getFilterKey: -> "name"

    confirmed: (item) -> new PostView item, @token

    cancelled: -> @panel.hide()

    # PRIVATE METHODS
    _create: ->
        @_getAllItems()
        items = []
        [ch, u] = [null, null]
        while not ch? and not u?
            [ch, u] = [@channels, @users]
        for i in [ch..., u...]
            [v, t] = if i.profile? then [i.profile.real_name, 'user'] else [i.name, 'channel']
            items.push({id:i.id, name:v, type:t})
        @setItems items

        @addClass 'overlay from-top'
        @panel ?= atom.workspace.addModalPanel(item: @)
        @panel.show()
        @focusFilterEditor()

    _getAllItems: ->
      # loops till we have channels and users to post to,
      # then quits
      # needs improvement or better logic elsewhere, otherwise blocks
      # atom's loading for a bit too much
      if @channels.length == 0 and @users.length == 0
          @_getChannels()
          @_getUsers()
          timer = setTimeout @_getAllItems.bind(@), 5 * 1000
      else
          clearTimeout timer

    _getChannels: ->
      request({
          uri: 'https://slack.com/api/channels.list',
          qs: {'token': @token, 'exclude_archived': 1},
          json: true })
      .then( (body)=>
          if body['ok'] == false
              # handle error message
              console.log(body['error'])
          else
              console.log('got the chans')
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
              # handle error message
              console.log(body['error'])
          else
              console.log('got the users')
              @users = body['members']
      )
      .catch( (err) => console.log(err) )
