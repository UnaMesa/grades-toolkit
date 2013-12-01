
Template.navbar.helpers
    activeRouteClass: ->
        args = Array::slice.call(arguments, 0)
        args.pop()
        active = _.any(args, (name) ->
            Session.get('path') is Router.routes[name]?.path()
        )
        active and 'active'

Template.moreNav.events
    "click #logout": (e, tmpl) ->
        e.stopPropagation();
        e.preventDefault();
        Meteor.logout (error) ->
            if error
                alert("Logout Error")
                # Show Error?
            else
                Router.go("home")

# Activate Bootstrap tooltips
Template.navbar.rendered = ->
    $("[rel='tooltip']").tooltip()
 
