
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
        'name': 1
    , 
        10

Meteor.startup ->
    console.log("Meteor Start on Client")
    #console.log("URL:",document.URL)
    if /mobile/i.test(navigator.userAgent)
        console.log('Mobile Device')
    else
        console.log("Not a mobile device", window)
        #window.open(Meteor.absoluteUrl(), 'Grades Demo', "height=600,width=400")

