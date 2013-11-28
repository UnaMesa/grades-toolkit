

Meteor.publish "userData", ->
    Meteor.users.find
        _id: @userId
    ,
        fields:
            'tag': 1
            'commentsCount': 1
            'createdAt': 1
            'services.google.picture': 1
            'services.google.given_name': 1
            'services.google.family_name': 1
            'services.google.email': 1
            'services.google.accessToken': 1
            'services.google.refreshToken': 1
            'services.google.expiresAt': 1


Meteor.publish "contacts", (limit) ->
    cursors = []
    cursors.push Meteor.users.find {},
        sort:
            'services.google.family_name': 1
            'services.google.given_name': 1
        fields:
            'tag': 1
            'lastLoginAt': 1
            'commentsCount': 1
            'profile.name': 1
            'services.google.email': 1
            'services.google.picture': 1
            'services.google.given_name': 1
            'services.google.family_name': 1
        limit: limit

    # Add more ?

    cursors

Meteor.publish "messages", (limit) ->
    Messages.find {},
        sort: 
            timestamp: -1
        limit: limit

Meteor.publish "families", (limit) ->
    Families.find {},
        sort: 
            name: 1
        limit: limit

Meteor.publish "singleFamily", (id) ->
    if id
        Families.find(id)


Meteor.publish "familyPhotos", (family_id) ->
    if family_id
        FamilyPhotos.find(family_id: family_id)


# TODO: Limit this to the ones a user can see 
Meteor.publish "cases", (limit) ->
    Cases.find {},
        sort:
            modified: -1
        limit: limit

Meteor.publish "singleCase", (id) ->
    if id
        Cases.find(id)



