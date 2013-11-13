# Make sure collection is global with '@'

@BID = {}

@BID.schema =
    childId:
        type: String
        #unique: true
        label: 'Child ID'
        optional: true  #  Have to check independent of Collection2
    stayInCurrentSchool:
        type: Boolean
        optional: true
        label: 'Remain in current school'
    date:
        type: Date
        optional: true
        label: 'BID Meeting Date'
    grade:
        type: Number
        min: 0
        max: 12
        label: "Current Grade"
        optional: true  #  Have to check independent of Collection2
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
    newSchool:
        type: String
        optional: true
        label: "Name of New School"


@BID.reasonsForChange = [
    "Child's permanency plan"
    "Parents/Custodians recommend change"
    "Commute too long"
    "Negative environment at current school"
    "Short time at current school"
    "Safety Issues"
    "New school has positive factors (social, emotional, academic, special needs)"
]


@BID.documentsUsed = [
    "Report Card"
    "Progress Reports"
    "Achievement Data"
    "IEP"
    "Other"
]

@BID.simpleSchema = new SimpleSchema(BID.schema)


# MOU
@MOU = {}

@MOU.schema =
    placeholder:
        type: String
        optional: true

@MOU.simpleSchema = new SimpleSchema(@MOU.schema)

@CaseSchema =
    name:
        type: String
        unique: true
    age:
        type: Number
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
    BID:
        type: @BID.simpleSchema
        optional: true
    MOU:
        type: @MOU.simpleSchema
        optional: true



@Cases = new Meteor.Collection2 'cases', 
    schema: CaseSchema


Meteor.methods 
    newCase: (caseAttributes) ->
        user = Meteor.user()
        
        # ensure the user is logged in
        throw new Meteor.Error(401, "You need to login to post new stories") unless user
  
        # ensure the post has a Name
        #throw new Meteor.Error(422, "Please fill in the name") unless caseAttributes.name
  
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
            theCase.tag = createCaseTag(caseAttributes.name)

        
        theCase = massageFormData(theCase, CaseSchema)

        console.log("Case", theCase)

        try   
            Cases.insert theCase
        catch error
            console.log("Error on new case insert", error, Cases.namedContext?("default").invalidKeys?())
            result =
                error: 
                    reason: "Error on new case insert"
                    invalidKeys: Cases.namedContext("default").invalidKeys()


    updateCase: (caseId, caseAttributes, type) ->
        user = Meteor.user()
        
        # ensure the user is logged in
        throw new Meteor.Error(401, "You need to login to create BIDs") unless user

        theCase = _.omit(caseAttributes, ["author", "userId", "submitted", "commentsCount"])
        
        theCase.modified = new Date().getTime()
        theCase.lastModifierId = user._id
        
        if theCase.BID?
            invalidKeys = []
            for key in ["childId", "grade"]
                console.log("Check", key, BID.schema[key])
                if not theCase.BID[key] or theCase.BID[key] is ''
                    invalidKeys.push
                        message: "#{BID.schema[key].label} is required"
                        name: key

            if invalidKeys.length > 0
                result =
                    error:
                        reason: "Error on BID update"
                        invalidKeys: invalidKeys
                return result

            theCase.BID = massageFormData(theCase.BID, BID.schema)

        console.log("Update Case", theCase)
        try
            rtn = Cases.update 
                _id: caseId
            ,
                $set: theCase
        catch error
            console.log("Error on new case update", error, Cases.namedContext?("default").invalidKeys?())
            result =
                error: 
                    reason: "Error on case update"
                    invalidKeys: Cases.namedContext("default").invalidKeys()
            return result

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
                _id: caseId

            if caseTag?
                message.tags.push caseTag

            switch type
                when 'BID'
                    message.message = "BID saved for #{caseTag.tag} by #{user.tag}"
                when 'MOU'
                    message.message = "MOU saved for #{caseTag.tag} by #{user.tag}"
                else
                    type = 'case'
                    message.message = "Case #{caseTag.tag} updated by #{user.tag}"

            Messages.insert message, (error, id) ->
                if error
                    console.log("Error creating tag for #{type} update")





