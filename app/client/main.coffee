
Meteor.subscribe "userData"

@ContactsHandle = Meteor.subscribeWithPagination "contacts", 
        'services.google.family_name': 1
        'services.google.given_name': 1
    , 
        7

@MessagesHandle = Meteor.subscribeWithPagination "messages", 
        timestamp: -1
    ,
        7

window.addEventListener "load", ->
    # Set a timeout...
    setTimeout ->
        # Hide the address bar!
        window.scrollTo(0, 1);
    , 0
