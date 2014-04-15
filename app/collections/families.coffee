#
#  Family Resources Collection
#

@Families = new Meteor.Collection('families')

@FamilyPhotos = new Meteor.Collection('familyPhotos')

Meteor.methods
    
    insertFamilyPhoto: (photo, options) ->
        console.log("insertFamilyPhoto", options)
        user = Meteor.user()

        # ensure the user is logged in
        throw new Meteor.Error(401, "Need to be logged in")  unless user

        if not options.familyId? or not family = Families.findOne(_id: options.familyId)
            throw new Meteor.Error(401, "Could not find family to attach photo")

        # pick out the whitelisted keys
        thePhoto = _.extend(photo,
            family_id: options.familyId
            userId: user._id
            lastModifierId: user._id
            author: user.profile.name
            submitted: new Date().getTime()
            modified: new Date().getTime()
        )

        try
            photoId = FamilyPhotos.insert(thePhoto)

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

                familyTag = fillOutTagFromId
                    type: 'family'
                    _id: options.familyId

                if familyTag?
                    message.tags.push familyTag

                message.message = "Family #{familyTag.tag} photo added by #{user.tag}"

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

