request = require 'request-promise'

module.exports =

  config:
      token:
          type: 'string'
          default: ''

  activate: (state) ->
      @postUrl = 'https://slack.com/api/chat.postMessage'
      @channelsUrl = 'https://slack.com/api/channels.list'
      @token = atom.config.get('atom-slack-snippets.token')
      atom.commands.add('atom-workspace', 'atom-slack-snippets:post', => @post())

  deactivate: ->

  post: ->
      #@getChannels()
      editor = atom.workspace.getActivePaneItem()
      selection = editor.getSelectedText()
      request({
          uri: @postUrl,
          qs: {
              'token': @token,
              'text': "```#{ selection }```",
              'channel': '# sandbox',
              'as_user': true
          },
          json: true })
      .then( (body)=>
          if body['ok'] == false
              console.log(body['error'])
      )
      .catch( (err) => console.log(err) )

  getChannels: ->
      payload =
      request({
          uri: @channelsUrl,
          qs: {'token': @token, 'exclude_archived': 1},
          json: true })
      .then( (body)=>
          if body['ok'] == false
              console.log(body['error'])
      )
      .catch( (err) => console.log(err) )
