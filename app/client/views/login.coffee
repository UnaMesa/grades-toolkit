
demoHeight = 400
demoWidth = 320

Template.login.helpers
    "doDemoLaunch": ->
        console.log("doDemoLaunch", window.innerWidth, window.innerHeight)
        not /mobile/i.test(navigator.userAgent) and window.innerWidth isnt demoWidth and window.innerHeight isnt demoHeight

Template.login.events
    "click #login": (e, tmpl) ->
        Meteor.loginWithGoogle
            requestPermissions: googleScopes
            forceApprovalPrompt: false
            requestOfflineToken: false
        ,
            (error) ->
                if error
                    # This is returning something regardless
                    console.log("Login Error", error)
                    CoffeeAlerts.error(Google Login Failed)
                    #throw new Meteor.Error(Accounts.LoginCancelledError.numericError, "Error")
                console.log("Go Home")
                Router.go('home')

    "click #demo": (e, tmpl) ->
        console.log("Launch Demo")
        newWindow = window.open(Meteor.absoluteUrl(), 'Grades Demo', "height=#{demoHeight},width=#{demoWidth},resizable=no")
        if (newWindow.focus)
            newWindow.focus()
        window.location = "http://unamesa.org"


