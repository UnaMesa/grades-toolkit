#
# Photo Methods
#

Meteor.methods

    submitPhoto: (photo, options) ->
        user = Meteor.user()

        # ensure the user is logged in
        throw new Meteor.Error(401, "Need to be logged in")  unless user

        throw new Meteor.Error(401, "Bad Photo Upload request")  unless options?.recordId?

        throw new Meteor.Error(401, "Bad Photo Upload request")  unless options?.recordType?
        
        switch options?.recordType
            when 'user'
                collectionToUpdate = Meteor.users
            when 'case'
                collectionToUpdate = Cases._collection # By passing Collection2
            when 'family'
                # TODO: Multiple Photos
                collectionToUpdate = Families
            else
                throw new Meteor.Error(401, "Bad Photo Upload request")

        modifier =
            picture: photo
            modified: new Date().getTime()
            lastModifierId: user._id

        try
            rtn = collectionToUpdate.update
                _id: options.recordId
            ,
                $set: modifier

        catch error
            console.log("Error on submitPhoto", error, collectionToUpdate.simpleSchema?().namedContext?("default").invalidKeys?())
            result =
                error: 
                    reason: "Error on submitting photo"
                    invalidKeys: collectionToUpdate.simpleSchema?().namedContext?("default").invalidKeys?()
            return result


