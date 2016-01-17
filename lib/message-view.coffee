{SelectListView} = require 'atom-space-pen-views'


module.exports =

class MessageListView extends SelectListView
    initialize: (message)->
        super
        @setItems [message]
        @addClass 'overlay from-top'
        @panel ?= atom.workspace.addModalPanel(item: @)
        @panel.show()
        @focusFilterEditor()

    viewForItem: (item) -> "<li>#{ item }</li>"

    confirmed: (item) ->
        @panel.hide()

    cancelled: ->
        @panel.hide()

    destroy: ->
        @view = null
        @panel = null
