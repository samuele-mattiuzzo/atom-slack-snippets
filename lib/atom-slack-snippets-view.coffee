request = require 'request-promise'
{SelectListView} = require 'atom-space-pen-views'


module.exports =

class AtomSlackSnippetsView extends SelectListView
    initialize: (channels, users, token, txt)->
        super
        @token = token
        @txt = @_escapeSelection txt
        @addClass 'overlay from-top'
        @items = []
        for i in [channels..., users...]
            v = if i.profile? then i.profile.real_name else i.name
            @items.push({id:i.id, name:v})
        @setItems @items
        @panel ?= atom.workspace.addModalPanel(item: this)
        @panel.show()
        @focusFilterEditor()

    viewForItem: (item) -> "<li>#{ item.name }</li>"

    getFilterKey: -> "name"

    _escapeSelection: (txt) ->
        # removes incompatible ``` from selection
        # avoids breaking out of the code block
        txt = txt.replace /\`\`\`/g, ''
        txt

    confirmed: (item) ->
        request({
            uri: 'https://slack.com/api/chat.postMessage',
            qs: {
                'token': @token,
                'text': "```#{ @txt }```",
                'channel': "#{ item.id }",
                'as_user': true,
                'parse': 'full'
            },
            json: true })
        .then( (body)=>
            if body['ok'] == false
                console.log body['error']
            else
                @panel.hide()
        )
        .catch( (err) => console.log err )

    cancelled: ->
        console.log "This view was cancelled"
        @panel.hide()
