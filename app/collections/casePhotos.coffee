
@CasePhotos = new Meteor.Collection('casePhotos')

Meteor.methods
    
    insertCasePhoto: (photo, options) ->
        user = Meteor.user()

        # ensure the user is logged in
        throw new Meteor.Error(401, "Need to be logged in")  unless user

        if not options.caseId? or not theCase = Cases.findOne(_id: options.caseId)
            throw new Meteor.Error(401, "Could not find case to attach photo")

        # pick out the whitelisted keys
        thePhoto = _.extend(photo,
            case_id: options.caseId
            userId: user._id
            lastModifierId: user._id
            author: user.profile.name
            submitted: new Date().getTime()
            modified: new Date().getTime()
        )

        try
            photoId = CasePhotos.insert(thePhoto)

             # Only available on the server
            if not @isSimulation
            
                # Generate Message
                message = 
                    userId: user._id
                    author: user.profile.name # Change to bot....
                    timestamp: new Date().getTime()
                    tags: []

                message.tags.push 
                    type: 'user'
                    _id: user._id
                    tag: user.tag
                    name: user.profile.name

                caseTag = fillOutTagFromId
                    type: 'case'
                    _id: options.caseId

                if caseTag?
                    message.tags.push caseTag

                message.message = "Case #{caseTag.tag} photo added by #{user.tag}"

                try
                    Messages.insert(message)
                    updateCommentsCounts(message)
                catch error
                    console.log("Error creating message on photo insert", error)

            photoId

        catch error
            console.log("Error on submitting photo", error)
            result =
                error: 
                    reason: "Error on submitting photo"

