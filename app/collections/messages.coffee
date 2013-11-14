
# Make sure collection is global with '@'
@Messages = new Meteor.Collection('messages')


Meteor.methods 
    submitMessage: (messageAttributes, tags) ->
        user = Meteor.user()
        
        if tags? and not typeIsArray tags
            tags = [tags]

        # ensure the user is logged in
        throw new Meteor.Error(401, "You need to login to post new stories") unless user
  
        # ensure the message has a mesage!!!
        throw new Meteor.Error(422, "Message is empty") unless messageAttributes.message
  
        # pick out the whitelisted keys
        message = _.extend(_.pick(messageAttributes, "message"),
            #title: postAttributes.title + (if @isSimulation then "(client)" else "(server)")
            userId: user._id
            author: user.profile.name
            timestamp: new Date().getTime()
        )

        # Only available on the server
        if not @isSimulation
            message.tags = []

            # Current User Tag
            message.tags.push
                type: 'user'
                _id: user._id
                tag: user.tag
                name: user.profile.name

            # Tags in the message
            if tags?
                tags = uniqueTags(tags)
                for tag in tags
                    message.tags.push(fillOutTagFromId(tag))
                    
            # Pull out tags in this message
            caseStrings = message.message.match(/\#[^ ]+/g)
            otherStrings = message.message.match(/\@[^ ]+/g)
            tagStrings = _.union(caseStrings, otherStrings)
            console.log(tagStrings, otherStrings, tagStrings)
            if tagStrings?
                for tagString in tagStrings
                    if tagString?
                        if tagObj = tagToTagObject(tagString)
                            message.tags.push(tagObj)
                        else
                            throw new Meteor.Error(422, "Invalid tag #{tagString} in message")
            message.tags = uniqueTags(message.tags)
            console.log("submitMessage", message)

            for tag in message.tags
                updateCommentsCount(tag)

        Messages.insert(message)



