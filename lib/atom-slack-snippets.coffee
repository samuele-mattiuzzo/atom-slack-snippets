{CompositeDisposable} = require 'atom'
SelectTokenView = require './select-token-view'


module.exports =

  config:
      tokens:
          type: 'array'
          default: []
          items:
              type: 'string'
              default: ''

  activate: (state) ->
      @subscriptions = new CompositeDisposable
      @subscriptions.add atom.commands.add 'atom-workspace',
          'atom-slack-snippets:post': => @post()

  destroy: ->
      @view = null
      @subscriptions.dispose()

  post: ->
      # don't fetch token here, use SelectTokenView
      # pipeline
      # 1. SelectTokenView, confirmed calls #2 [done]
      # 2. SelectChannelView (uses the token fetched in #1, gets channels and users) [done]
      # 3. Calls PostView (move current atom slack snippets view in here) [done]
      # MessageView (opens a panel with the message specified as param)
      # this view also handles errors when they need to be displayed to the user
      @view = new SelectTokenView
