
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


Meteor.startup ->
    console.log("Meteor Start on Client")
    ###
    cursor = Messages.find()
    cursor.observe
        addedAt: (message, atIndex, before) ->
            if not before and message.userId != Meteor.userId()
                console.log("New Message")
                document.getElementById('newMessageSound').play()
    ###

    
    ###
    oldMessageCount = Messages.find().count()
    Deps.autorun ->
        console.log("Play new sound?", oldMessageCount, Messages.find().count())
        if Messages.find().count() > oldMessageCount
            oldMessageCount = Messages.find().count()
            console.log("Play new sound", Messages.find().count())
            document.getElementById('newMessageSound').play()
    ###

#
# Trying to hide browers bar on iOS.  TODO: Get this to work
#
window.addEventListener "load", ->
    # Set a timeout...
    setTimeout ->
        # Hide the address bar!
        window.scrollTo(0, 1)
    , 0
