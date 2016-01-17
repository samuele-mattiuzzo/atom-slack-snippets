{SelectListView} = require 'atom-space-pen-views'
SelectChannelView = require './select-channel-view'
MP = require './message-view'


module.exports =

class SelectTokenView extends SelectListView
    # token is an array in atom.config
    # contains objects of type {name:str, token:str}
    # name will be displayed in the list
    # token will be used to create the channels
    initialize: ->
        super

        @addClass 'overlay from-top'
        @setItems @_createItems()
        @panel ?= atom.workspace.addModalPanel(item: @)

        if @items?.length
            @panel.show()
            @focusFilterEditor()
        else
            new MP 'Please add token(s) to your settings'

    viewForItem: (item) -> "<li>#{ item.name }</li>"

    getFilterKey: -> "name"

    confirmed: (item) ->
        @view = new SelectChannelView item.token

    cancelled: ->
        @panel.hide()

    destroy: ->
        @view = null
        @panel = null

    # PRIVATE METHODS
    _createItems: ->
        tokens = atom.config.get 'atom-slack-snippets.tokens'
        items = []
        for item in tokens
            [n, t] = item.split "|"
            items.push {'name': n, 'token': t}
        items
