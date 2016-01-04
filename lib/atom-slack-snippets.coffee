module.exports =

  config:
      token:
          type: 'string'

  activate: (state) ->
      @postUrl = 'https://slack.com/api/chat.postMessage'
      @channelsUrl = 'https://slack.com/api/channels.list'
      @panel ?= atom.workspace.addModalPanel(item: @, visible: true)
      @.focus()
      atom.commands.add(@element, 'atom-slack-snippets:post', => @post())

  deactivate: ->

  post: ->

      @getChannels()

      editor = atom.workspace.activePaneItem
      selection = editor.getSelection().getText()

      payload = {
          'token': @token,
          'text': selection,
      }

  getChannels: ->
      payload = { 'token': @token, 'exclude_archived': 1 }
      request({ uri:"#{ @cst.apiUrl }/#{ woeid }/", json: true })
      .then( (body)=>

      )
      .catch( (err) => console.log("[ERROR] Couldn't fetch channels:  #{ err }") )
