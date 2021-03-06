class Dashing.Retention extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.


    onData: (data) ->
    if (@get('color') == "default")
      color = '$background-color'

    else 
      color = @get('color')

    $(@node).css('background-color', color)
    $(@node).css('hide-color', color)
