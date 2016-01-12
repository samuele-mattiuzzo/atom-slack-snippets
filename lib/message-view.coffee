module.exports =
    class Message

        constructor: ->
            # Create root element
            @element = document.createElement('div')
            @element.classList.add('snippets')

            # Create message element
            message = document.createElement('div')
            message.classList.add('message')
            @element.appendChild(message)

        setMessage: (message) ->
            debugger
            @element.children[0].textContent = message

        destroy: ->
            @element.remove()

        getElement: ->
            @element
