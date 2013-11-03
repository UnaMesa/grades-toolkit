#
#  Utility Functions
#

#
#  create a Unique Tag
#     todo: errors?
#
@createTag = (tagFromString) ->
    baseTag = '#'
    # First attempt is just initials
    parts = tagFromString.toLowerCase().split(" ")
    for part in parts
        baseTag += part[0]

    # Check if this tag exists already
    tag = baseTag
    counter = 0
    while Meteor.users.findOne(tag: tag) or Cases.findOne(tag: tag) or Families.findOne(tag: tag)
        counter++
        tag = baseTag + counter
    console.log("createTag", tag)
    tag

@tagToTagObject = (tag) ->
    
    #tagObject = Meteor.users.findOne(tag: tag)
    if tagObject = Meteor.users.findOne(tag: tag)
        
        tagObject =
            type: 'user'
            _id: tagObject._id
            tag: tag
            name: tagObject.profile.name
    
    else if tagObject = Cases.findOne(tag: tag)
        
        tagObject =
            type: 'case'
            _id: tagObject._id
            tag: tag
            name: tagObject.name

    else if tagObject = Families.findOne(tag: tag)
        
        tagObject =
            type: 'family'
            _id: tagObject._id
            tag: tag
            name: tagObject.name

@updateCommentsCount = (tag) ->
    console.log("update comments count", tag)
    if tag.type is 'user'
        collectionToUpdate = Meteor.users
    else if tag.type is 'case'
        collectionToUpdate = Cases
    else if tag.type is 'family'
        collectionToUpdate = Families

    collectionToUpdate.update
        _id: tag._id
    ,
        $inc:
            commentsCount: 1


