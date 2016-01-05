{request} = require 'request-promise'
{CompositeDisposable} = require 'atom'
AtomSlackSnippetsView = require './atom-slack-snippets-view'

module.exports =

  config:
      token:
          type: 'string'
          default: ''

  activate: (state) ->
      @token = atom.config.get('atom-slack-snippets.token')
      @channels = []
      @users = []

      atom.commands.add('atom-workspace', 'atom-slack-snippets:post', => @post())

  deactivate: ->
      @view = null
      @channels = null
      @users = null

  post: ->
      if @token?
          @_getChannels()
          @_getUsers()
          editor = atom.workspace.getActivePaneItem()
          selection = editor.getSelectedText()
          @view = new AtomSlackSnippetsView(@channels, @users, @token, selection)

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
