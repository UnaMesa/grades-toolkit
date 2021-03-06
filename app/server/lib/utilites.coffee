#
#  Utility Functions
#

#
#  create a Unique Tag
#     todo: errors?
#


@createFamilyTag = (tagFromString) ->
    baseTag = '#'
    # First attempt is just initials
    parts = tagFromString.toLowerCase().split(" ")
    for part in parts
        if part?[0]?
            baseTag += part[0]

    # Check if this tag exists already
    tag = baseTag
    counter = 0
    while Families.findOne(tag: tag)
        counter++
        tag = "#{baseTag}#{counter}"
    tag

@createCaseTag = (tagFromString) ->
    baseTag = '#'
    # First attempt is just initials
    parts = tagFromString.toLowerCase().split(" ")
    for part in parts
        if part?[0]?
            baseTag += part[0]

    # Check if this tag exists already
    tag = baseTag
    counter = 0
    while Cases.findOne(tag: tag)
        counter++
        tag = baseTag + counter
    tag


@createUserTag = (tagFromString) ->
    baseTag = '@'
    # First attempt is just initials
    parts = tagFromString.toLowerCase().split(" ")
    for part in parts
        if part?[0]?
            baseTag += part[0]

    # Check if this tag exists already
    tag = baseTag
    counter = 0
    while Meteor.users.findOne(tag: tag) or Families.findOne(tag: tag)
        counter++
        tag = baseTag + counter
    tag


@tagToTagObject = (tag) ->
    if tag?[0] is '@'
        if tagObject = Meteor.users.findOne(tag: tag)
            tagObject =
                type: 'user'
                _id: tagObject._id
                tag: tag
                name: tagObject.profile.name
    else if tag?[0] is '#'
        if tagObject = Cases.findOne(tag: tag)
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
                name: "#{tagObject.firstname} #{tagObject.lastname}"


@fillOutTagFromId = (tag) ->
    if tag?
        switch tag?.type
            when 'user'
                if rec = Meteor.users.findOne(_id: tag._id)
                    tag.name = rec.profile.name
            when 'case'
                if rec = Cases.findOne(_id: tag._id)
                    tag.name = rec.name
            when 'family'  
                if rec = Families.findOne(_id: tag._id)
                    tag.name = "#{rec.firstname} #{rec.lastname}"
        tag.tag = rec?.tag
        tag


@fillOutTagFromTag = (tag) ->
    switch tag?.type
        when 'user'
            if rec = Meteor.users.findOne(tag: tag.tag)
                tag.name = rec.profile.name
        when 'case'
            if rec = Cases.findOne(tag: tag.tag)
                tag.name = rec.name
        when 'family'
            if rec = Families.findOne(tag: tag.tag)
                tag.name = rec.name
    tag._id = rec?._id
    tag


@updateCommentsCount = (tag) ->
    switch tag?.type
        when 'user'
            collectionToUpdate = Meteor.users
        when 'case'
            collectionToUpdate = Cases
        when 'family'
            collectionToUpdate = Families
        else
            return false

    collectionToUpdate.update tag._id,
        $inc:
            commentsCount: 1
    , (error, result) ->
        if error
            console.log("updateCommentsCount error", tag, error)
    true

@updateCommentsCounts = (message) ->
    for tag in message.tags
        updateCommentsCount(tag)



