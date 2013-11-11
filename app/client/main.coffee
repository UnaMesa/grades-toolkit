
Meteor.subscribe "userData"

@ContactsHandle = Meteor.subscribeWithPagination "contacts", 
        'services.google.family_name': 1
        'services.google.given_name': 1
    , 
        10

@MessagesHandle = Meteor.subscribeWithPagination "messages", 
        timestamp: -1
    ,
        10

@CasesHandle = Meteor.subscribeWithPagination "cases", 
        modified: -1
    ,
        10

@FamiliesHandle = Meteor.subscribeWithPagination "families", 
        'Last Name': 1
        'First Name': 1
    , 
        10

Meteor.startup ->
    console.log("Meteor Start on Client")
    #console.log("URL:",document.URL)
    if /mobile/i.test(navigator.userAgent)
        console.log('Mobile Device')
        $ ->
            FastClick.attach document.body

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

