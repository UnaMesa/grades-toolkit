
# Make sure collection is global with '@'
@Messages = new Meteor.Collection('messages')


Meteor.methods 
    submitMessage: (messageAttributes) ->
        user = Meteor.user()
        
        # ensure the user is logged in
        throw new Meteor.Error(401, "You need to login to post new stories") unless user
  
        # ensure the message has a mesage!!!
        throw new Meteor.Error(422, "Message is empty")  unless messageAttributes.message
  
        # pick out the whitelisted keys
        message = _.extend(_.pick(messageAttributes, "message"),
            #title: postAttributes.title + (if @isSimulation then "(client)" else "(server)")
            userId: user._id
            author: user.profile.name
            timestamp: new Date().getTime()
        )

        Messages.insert(message)
