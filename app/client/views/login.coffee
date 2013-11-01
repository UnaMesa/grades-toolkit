

Template.login.events
    "click #login": (e, tmpl) ->
        Meteor.loginWithGoogle
            requestPermissions: [
                "https://www.googleapis.com/auth/userinfo.email",
                #"https://www.googleapis.com/auth/drive.file"   # Files created by this app ?!?!
                "https://www.googleapis.com/auth/drive"   # All files?
            ]
            forceApprovalPrompt: true
            requestOfflineToken: true
        ,
            (error) ->
                if error
                    # This is returning something regardless
                    console.log("Login Error", error)
                    throw new Meteor.Error(Accounts.LoginCancelledError.numericError, "Error")
                Router.go('home')

