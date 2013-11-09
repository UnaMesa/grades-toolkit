#
# User Methods
#

Meteor.methods

    userLoggedIn: ->
        console.log("User Login", Meteor.userId())
        Meteor.users.update
            _id: Meteor.userId()
        ,
            $set:
                lastLoginAt: new Date().getTime()

 


