#
#  Family Resources Collection
#

@Families = new Meteor.Collection('families')


@FamilyPhotos = new Meteor.Collection('familyPhotos')

Meteor.methods
    
    insertFamilyPhoto: (photo, options) ->
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
            rtn = FamilyPhotos.insert(thePhoto)

        catch error
            console.log("Error on submitting photo", error)
            result =
                error: 
                    reason: "Error on submitting photo"
