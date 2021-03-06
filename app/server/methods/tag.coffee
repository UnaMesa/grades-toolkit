#
# Tagging server methods
#

Meteor.methods

    createUserTag: (tagFromString) ->
        createUserTag(tagFromString)

    createCaseTag: (tagFromString) ->
        createCaseTag(tagFromString)

    getFullTag: (tag) ->
        if tag.type? and tag._id?
            fillOutTagFromId(tag)
        else if tag.type? and tag.tag?
            fillOutTagFromTag(tag)
        else if tag.tag?
            tagToTagObject(tag.tag)
        else
            tagToTagObject(tag)

    addUserTag: ->
        user = Meteor.user()
        # ensure the user is logged in
        throw new Meteor.Error(401, "Error not Logged In!") unless user
  
        name = user.profile.name
        tag = createUserTag(name)
        Meteor.users.update 
            _id: user._id
        ,
            $set:
                tag: tag

    tagIsValid: (tag) ->
        Meteor.users.findOne(tag: tag) or Cases.findOne(tag: tag) or Families.findOne(tag: tag)

 


