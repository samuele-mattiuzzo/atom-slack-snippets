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
      @subscriptions.add atom.config.onDidChange 'atom-slack-snippets.token', =>
          @destroy()
          @setUp()

      @subscriptions.add atom.commands.add 'atom-workspace',
          'atom-slack-snippets:post': => @post()

  setUp: ->
      @token = atom.config.get('atom-slack-snippets.token')
      @channels = []
      @users = []
      @_getAllItems()

  deactivate: ->
      @destroy()

  destroy: ->
      @view = null
      @channels = null
      @users = null
      @subscriptions = null

  post: ->
      if @token?
          editor = atom.workspace.getActivePaneItem()
          selection = editor.getSelectedText()
          @view = new AtomSlackSnippetsView(@channels, @users, @token, selection)

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
