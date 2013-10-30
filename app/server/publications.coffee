

Meteor.publish "userData", ->
    Meteor.users.find
        _id: @userId
    ,
        fields:
            'services.google.picture': 1
            'services.google.given_name': 1


Meteor.publish "contacts", (limit) ->
    Meteor.users.find {},
        sort:
            'services.google.family_name': 1
            'services.google.given_name': 1
        fields:
            'profile.name': 1
            'services.google.picture': 1
            'services.google.given_name': 1
            'services.google.family_name': 1
        limit: limit


Meteor.publish "messages", (limit) ->
    Messages.find {},
        sort: 
            timestamp: -1
        limit: limit

# TODO: Limit this to the ones a user can see 
Meteor.publish "cases", (limit) ->
    Cases.find {},
        sort:
            modified: -1
        limit: limit

Meteor.publish "singleCase", (id) ->
    if id
        Cases.find(id)