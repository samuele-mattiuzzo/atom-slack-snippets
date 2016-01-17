request = require 'request-promise'
{SelectListView} = require 'atom-space-pen-views'
MP = require './message-view'


module.exports =

class PostView extends SelectListView
    # fetches the selected text and posts to the channel (item)
    # using token
    initialize: (item, token)->
        super
        @panel ?= atom.workspace.addModalPanel({item: @, visible: false})

        @target = item
        @token = token
        @txt = @_escapeSelection()

        if item.type == 'user'
            # we need to open an IM channel with the user before sending to him
            @_postToUser item.id
        else
            @_postToChannel item.id

    # PRIVATE METHODS
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
                # handle error message
                new MP body['error']
            else
                # handle success message
                new MP 'Your message has been sent'
        )
        .catch( (err) => console.log err )

    _postToUser: (userId) ->
        request({
            uri: 'https://slack.com/api/im.open',
            qs: { 'token': @token, 'user': userId },
            json: true })
        .then( (body)=>
            if body['ok'] == false
                # handle error message
                new MP body['error']
            else
                @_postToChannel body['channel']['id']
        )
        .catch( (err) => console.log err )

    _escapeSelection: ->
        editor = atom.workspace.getActivePaneItem()
        txt = editor.getSelectedText()
        # removes incompatible ``` from selection
        # avoids breaking out of the code block
        txt = txt.replace /\`\`\`/g, ''
        txt
