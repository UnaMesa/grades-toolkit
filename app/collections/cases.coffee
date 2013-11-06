# Make sure collection is global with '@'

@BIDSchema =
    childId:
        type: String
        #unique: true
        optional: true
        label: 'Child ID'
    stayInCurrentSchool:
        type: Boolean
        optional: true
        label: 'Remain in current school'
    bidDate:
        type: Date
        optional: true
        label: 'BID Meeting Date'
    grade:
        type: Number
        min: 0
        max: 12
        optional: true
        label: "Current Grade"
    currentSchool:
        type: String
        optional: true
        label: "Current School"
    reasonsForChange:
        type: [String]
        optional: true
        label: 'Reasons for Change'
    reasonsForChangeComments:
        type: String
        optional: true
        label: 'Document Reasons for Change'
    changeWillImpactStudent:
        type: Boolean
        optional: true
        label: 'Change will impact student'
    timingWillImpactGraduation:
        type: Boolean
        optional: true
        label: 'Timing will impact graduation'
    parentsAndSchoolInformedOfMeeting:
        type: Boolean
        optional: true
        label: "Child's parents and School informed of meeting"
    childConsulted:
        type: Boolean
        optional: true
        label: "Was Child consulted"
    documentsUsed:
        type: [String]
        optional: true
        label: "Documents used for BID"
    otherDocumentsUsed:
        type: String
        optional: true
        label: "Other documents used for BID"



@CaseSchema =
    name:
        type: String
        unique: true
    age:
        type: Number,
        min: 0
    urgent:
        type: Boolean
    location:
        type: String
        #optional: true
    author:
        type: String
    userId:
        type: String
    submitted:
        type: Number # Date?
    modified:
        type: Number # Date?
    commentsCount:
        type: Number
        optional: true
    "contact.name":
        type: String
        optional: true
    "contact.number":
        type: String
        optional: true
    tag:
        type: String
        unique: true
        optional: true
    # BID
    childId:
        type: String
        unique: true
        optional: true

@CaseSchema = _.extend(@CaseSchema, @BIDSchema)


@Cases = new Meteor.Collection2 'cases', 
    schema: CaseSchema


#
#  Add more permission stuff....
#

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

        try   
            Cases.insert theCase
        catch error
            console.log("Error on new case insert", error, Cases.namedContext?("default").invalidKeys?())
            result =
                error: 
                    reason: "Error on new case insert"
                    invalidKeys: Cases.namedContext("default").invalidKeys()
                
        ###
        , (error, result) ->
            if error
                console.log("Error on new Case insert", error, Cases.namedContext?("default").invalidKeys?())
                if Meteor.isClient
                    if Cases.namedContext?("default").invalidKeys?().length > 0
                        firstInvalidKey = Cases.namedContext("default").invalidKeys()[0]
                        CoffeeAlerts.error("New Case Failed: "+ firstInvalidKey.message)
                        $("[name=#{firstInvalidKey.name}]").parent().addClass('has-error')
                #throw new Meteor.Error(600, "Insert Failed")
        ###


    updateCase: (caseId, caseAttributes) ->
        user = Meteor.user()
        
        # ensure the user is logged in
        throw new Meteor.Error(401, "You need to login to create BIDs") unless user

        theCase = _.omit(caseAttributes, ["author", "userId", "submitted", "commentsCount"])
        
        theCase.modified = new Date().getTime()
        
        console.log("Update Case", caseId, theCase)
        try
            Cases.update caseId,
                $set: theCase
        catch error
            console.log("Error on new case update", error, Cases.namedContext?("default").invalidKeys?())
            result =
                error: 
                    reason: "Error on case update"
                    invalidKeys: Cases.namedContext("default").invalidKeys()
                


