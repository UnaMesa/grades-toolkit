
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


#
# Trying to hide browers bar on iOS.  TODO: Get this to work
#
window.addEventListener "load", ->
    # Set a timeout...
    setTimeout ->
        # Hide the address bar!
        window.scrollTo(0, 1)
    , 0
