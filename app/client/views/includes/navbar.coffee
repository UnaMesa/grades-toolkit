
Template.navbar.helpers
    activeRouteClass: ->
        args = Array::slice.call(arguments, 0)
        args.pop()
        active = _.any(args, (name) ->
            Session.get('path') is Router.routes[name]?.path()
        )
        active and 'active'

Template.navbar.events
    "click #logout": (e, tmpl) ->
        Meteor.logout (error) ->
            if error
                alert("Logout Error")
                # Show Error?
            else
                Router.go("home")

# Activate Bootstrap tooltips
Template.navbar.rendered = ->
    $("[rel='tooltip']").tooltip()
 