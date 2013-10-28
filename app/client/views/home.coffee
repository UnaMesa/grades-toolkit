

Template.home.events
    "click #login": (e, tmpl) ->
        Meteor.loginWithGoogle
            requestPermissions: [
                "https://www.googleapis.com/auth/userinfo.email",
                "https://www.googleapis.com/auth/drive.file"
            ]
            forceApprovalPrompt: false
            requestOfflineToken: false
        ,
            (error) ->
                if error
                    # This is returning something regardless
                    console.log("Login Error", error)
                    throw new Meteor.Error(Accounts.LoginCancelledError.numericError, "Error")
                Router.go('home')

Template.home.rendered = ->
    setTimeout ->
        # Hide the address bar!
        window.scrollTo(0, 1)
    , 1