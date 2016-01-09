request = require 'request-promise'
{CompositeDisposable} = require 'atom'
AtomSlackSnippetsView = require './select-token-view'


module.exports =

  config:
      tokens:
          type: 'array'
          default: []
          items:
              type: 'object'
              properties:
                  name:
                      type: 'string'
                      default: ''
                  token:
                      type: 'string'
                      default: ''


  activate: (state) ->
      @subscriptions = new CompositeDisposable
      @subscriptions.add atom.commands.add 'atom-workspace',
          'atom-slack-snippets:post': => @post()

  destroy: ->
      @view = null
      @subscriptions = null

  post: ->
      # don't fetch token here, use SelectTokenView
      # pipeline
      # 1. SelectTokenView, confirmed calls #2 [done]
      # 2. SelectChannelView (uses the token fetched in #1, gets channels and users) [done]
      # 3. Calls PostView (move current atom slack snippets view in here) [done]
      # MessageView (opens a panel with the message specified as param)
      # this view also handles errors when they need to be displayed to the user
      @view = new SelectTokenView
