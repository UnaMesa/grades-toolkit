



Template.login.events
    "click #login": (e, tmpl) ->
        Meteor.loginWithGoogle
            requestPermissions: googleScopes
            forceApprovalPrompt: true
            requestOfflineToken: true
        ,
            (error) ->
                if error
                    # This is returning something regardless
                    console.log("Login Error", error)
                    throw new Meteor.Error(Accounts.LoginCancelledError.numericError, "Error")
                Router.go('home')

