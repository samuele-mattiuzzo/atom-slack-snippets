request = require 'request-promise'
{SelectListView} = require 'atom-space-pen-views'


module.exports =

class AtomSlackSnippetsView extends SelectListView
    initialize: (channels, users, token, txt)->
        super
        @token = token
        @items = @_createItems channels, users
        @txt = @_escapeSelection txt

        @addClass 'overlay from-top'
        @setItems @items
        @panel ?= atom.workspace.addModalPanel(item: @)
        @panel.show()
        @focusFilterEditor()

    viewForItem: (item) ->
        "<li>#{ item.name }</li>"

    getFilterKey: ->
        "name"

    confirmed: (item) ->
        if item.type == 'user'
            # we need to open an IM channel with the user before sending to him
            @_postToUser(item.id)
        else
            @_postToChannel(item.id)

    cancelled: ->
        @panel.hide()

    _postToChannel: (channelId) ->
        request({
            uri: 'https://slack.com/api/chat.postMessage',
            qs: {
                'token': @token,
                'text': "```#{ @txt }```",
                'channel': channelId,
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

    _postToUser: (userId) ->
        request({
            uri: 'https://slack.com/api/im.open',
            qs: { 'token': @token, 'user': userId },
            json: true })
        .then( (body)=>
            if body['ok'] == false
                console.log body['error']
            else
                @_postToChannel(body['channel']['id'])
        )
        .catch( (err) => console.log err )

    _escapeSelection: (txt) ->
        # removes incompatible ``` from selection
        # avoids breaking out of the code block
        txt = txt.replace /\`\`\`/g, ''
        txt

    _createItems: (channels, users) ->
        items = []
        for i in [channels..., users...]
            [v, t] = if i.profile? then [i.profile.real_name, 'user'] else [i.name, 'channel']
            items.push({id:i.id, name:v, type:t})
        items
