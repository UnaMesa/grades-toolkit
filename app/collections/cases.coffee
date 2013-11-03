# Make sure collection is global with '@'
@Cases = new Meteor.Collection('cases')

Meteor.methods 
    newCase: (caseAttributes) ->
        user = Meteor.user()
        
        # ensure the user is logged in
        throw new Meteor.Error(401, "You need to login to post new stories") unless user
  
        # ensure the post has a Name
        throw new Meteor.Error(422, "Please fill in the name") unless caseAttributes.name
  
        caseWithSameName = Cases.findOne(name: caseAttributes.name)

        # check that there are no previous posts with the same name
        throw new Meteor.Error(302, "There is already a case with this name", caseWithSameName._id)  if caseWithSameName
  
        # pick out the whitelisted keys
        theCase = _.extend(_.pick(caseAttributes, "name", "sex", "age", "urgent", "location"),
            userId: user._id
            author: user.profile.name
            submitted: new Date().getTime()
            modified: new Date().getTime()
            commentsCount: 0
            contact:
                name: caseAttributes.contactName
                number: caseAttributes.contactNumber
        )

        # Only available on the server
        if not @isSimulation
            theCase.tag = createTag(caseAttributes.name)

        Cases.insert(theCase)
        
