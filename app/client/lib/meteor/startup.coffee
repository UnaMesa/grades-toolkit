

Deps.autorun ->
  if Meteor.user() and not Meteor.loggingIn()
    
    console.log("Set up Intercom")
    Meteor.call "getHash", Meteor.user().services?.google?.email, (error, result) ->
        Session.set "userEmailHash", result

    if Meteor.user() and Session.get("userEmailHash")
        intercomSettings =
            email: Meteor.user?().services?.google?.email
            created_at: Math.round(Meteor.user().createdAt / 1000)
            name: Meteor.user().services.google.given_name + ' ' + Meteor.user().services.google.family_name
            user_hash: Session.get("userEmailHash")
            widget:
                activator: '#Intercom'
                use_counter: true
            app_id: "6b4e12edd77380cb4b223fc8d76dd7f75f33259a"

        console.log("Intercom boot", intercomSettings)
        Intercom("boot", intercomSettings)

Meteor.startup ->
    console.log("Meteor Start on Client")
    #console.log("URL:",document.URL)
    if /mobile/i.test(navigator.userAgent)
        console.log('Mobile Device')
        $ ->
            #FastClick.attach document.body

            # Window hide scroll hack.  Does not work on iOS 7
            window.scrollTo(0, 0)
            Meteor.setTimeout ->
                window.scrollTo(0, 1)
            , 200

            landscape = window.orientation is 90 or window.orientation is -90
            Session.set("landscape", landscape)

            $(window).on "orientationchange", ->
                landscape = window.orientation is 90 or window.orientation is -90
                console.log("orientationchange", window.orientation, landscape)
                Session.set("landscape", landscape)
                
    else
        console.log("Not a mobile device", window)
        #window.open(Meteor.absoluteUrl(), 'Grades Demo', "height=600,width=400")

