
# Use to serialize a form into an object
$.fn.serializeObject = ->
    o = {}
    a = @serializeArray()
    $.each a, ->
        if o[@name] isnt `undefined`
            o[@name] = [o[@name]]  unless o[@name].push
            o[@name].push @value or ""
        else
            o[@name] = @value or ""
    o