#
#  Utility Functions
#

#
#  create a Unique Tag
#     todo: errors?
#
@createTag = (tagFromString) ->
    baseTag = ''
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

