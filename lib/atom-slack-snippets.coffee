request = require 'request-promise'
{CompositeDisposable} = require 'atom'
AtomSlackSnippetsView = require './atom-slack-snippets-view'

module.exports =

  config:
      token:
          type: 'string'
          default: ''

  activate: (state) ->
      @setUp()
      @subscriptions = new CompositeDisposable
      @subscriptions.add atom.config.onDidChange 'token', =>
          @destroy()
          @setUp()

      @subscriptions.add atom.commands.add 'atom-workspace',
          'atom-slack-snippets:post': => @post()

  setUp: ->
      @token = atom.config.get('atom-slack-snippets.token')
      @channels = []
      @users = []

  deactivate: ->
      @destroy()

  destroy: ->
      @view = null
      @channels = []
      @users = []

  post: ->
      if @token?
          if @channels.length > 0 then '' else @_getChannels()
          if @users.length > 0 then '' else @_getUsers()
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
