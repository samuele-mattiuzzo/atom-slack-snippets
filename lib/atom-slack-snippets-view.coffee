{View} = require 'space-pen'

module.exports =
  class AtomSlackSnippetsView extends View

    initialize: ->
      @panel ?= atom.workspace.addModalPanel(item: @, visible: true)
      @.focus()
      atom.commands.add(@element, 'atom-slack-snippets:post', => @hideView())

    hideView: ->
      @panel.hide()
      @.focusout()
