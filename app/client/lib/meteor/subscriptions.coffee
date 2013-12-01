#
#  Subscriptions
#

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
