
Template.layout.rendered = ->
    if /mobile/i.test(navigator.userAgent)
        FastClick.attach document.body
    


