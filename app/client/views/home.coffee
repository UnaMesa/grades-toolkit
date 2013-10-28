

Template.home.events
    "click #login": (e, tmpl) ->
        Meteor.loginWithGoogle
            requestPermissions: ["email", "profile"]
            forceApprovalPrompt: false
            requestOfflineToken: false
        ,
            (error) ->
                if error
                    throw new Meteor.Error(Accounts.LoginCancelledError.numericError, "Error")
                Router.go('home')

Template.home.rendered = ->
    setTimeout ->
        # Hide the address bar!
        window.scrollTo(0, 1)
    , 1