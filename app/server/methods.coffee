#
# Methods
#

Meteor.methods
    newGoogleDoc: (doc) ->
        user = Meteor.user()
        console.log("Create a new google doc", doc, user)

        # ensure the user is logged in
        throw new Meteor.Error(401, "You need to be logged in to create docs")  unless user
  
        # ensure the doc has a title
        throw new Meteor.Error(422, "Please fill in a document title") unless doc.title
  