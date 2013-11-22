
demoHeight = 600
demoWidth = 400

Template.login.helpers
    "doDemoLaunch": ->
        console.log("doDemoLaunch", window.innerWidth, window.innerHeight)
        not /mobile/i.test(navigator.userAgent) and (window.innerWidth > demoWidth or window.innerHeight > demoHeight)

Template.login.events
    "click #login": (e, tmpl) ->
        Meteor.loginWithGoogle
            requestPermissions: googleScopes
            forceApprovalPrompt: false
            requestOfflineToken: true
        ,
            (error) ->
                if error
                    # This is returning something regardless
                    console.log("Login Error", error)
                    CoffeeAlerts.error(Google Login Failed)
                    #throw new Meteor.Error(Accounts.LoginCancelledError.numericError, "Error")
                else if not Meteor.user()?.tag 
                    # Need a Tag
                    console.log("No Tag for user", Meteor.user())
                    tag = Meteor.call 'addUserTag', Meteor.user().profile.name, (error, tag) ->
                        if error
                            console.log("Error on creating tag", error)
                        else
                            console.log("New Tag", tag)
                Meteor.call 'userLoggedIn', (error) ->
                    if error
                        console.log("Error on userLoggedIn", error)
                console.log("Go Home")
                Router.go('home')
        gDrive.reAuthorize()

    "click #demo": (e, tmpl) ->
        console.log("Launch Demo")
        newWindow = window.open(Meteor.absoluteUrl(), 'Grades Demo', "height=#{demoHeight},width=#{demoWidth},resizable=no")
        if (newWindow.focus)
            newWindow.focus()
        window.location = "http://unamesa.org"

    "click #win-test": (e, tmpl) ->
        console.log("Win Test")
        newWindow = window.open("http://google.com", '_blank', "height=#{demoHeight},width=#{demoWidth},resizable=no")
        if (newWindow.focus)
            newWindow.focus()
        console.log("new Window?", newWindow)
        Meteor.setTimeout ->
            console.log("Close New Window", newWindow)
            newWindow.close()
            console.log("New Window Closed?", newWindow)
        , 3000
