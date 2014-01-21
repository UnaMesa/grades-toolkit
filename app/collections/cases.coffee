# Make sure collection is global with '@'

@BID = {}

@BID.schema =

    #
    # Documentation
    #

    childId:
        type: String
        #unique: true
        label: 'Child ID'
        optional: true  #  Have to check independent of Collection2
    currentSchool:
        type: String
        optional: true
        label: "Current School and District"
    previousSchools:
        type: String
        optional: true
        label: "Previous School(s)"
    grade:
        type: Number
        min: 0
        max: 12
        label: "Current Grade"
        optional: true  #  Have to check independent of Collection2
    date:
        type: Date
        optional: true
        label: 'BID Meeting Date'
    "bidAttendees.$.name":
        type: String
        optional: true
        label: "Name of person who attended/consulted for the BID meeting"
    "bidAttendees.$.role":
        type: String
        optional: true
        label: "Role of person who attended/consulted for the BID meeting"
    "bidAttendees.$.contactInfo":
        type: String
        optional: true
        label: "Contact for person who attended/consulted for the BID meeting"
    documentsUsed:
        type: [String]
        optional: true
        label: "Documents used for BID"
    otherDocumentsUsed:
        type: String
        optional: true
        label: "Other documents used for BID"

    #
    # Considerations
    #

    "considerations.$.key":
        type: String
        optional: true
    "considerations.$.yesNo":
        type: String
        optional: true
    "considerations.$.factors":
        type: String
        optional: true


    #
    # Summary
    #

    bidSummary:
        type: String
        optional: true
        label: "BID Summary"
    teamRecommendation:
        type: String
        optional: true
        label: 'Team Recommendation'
    schoolToAttend:
        type: String
        optional: true
        label: "School to Attend"
    susd:
        type: String
        optional: true
        label: "Student ID"

    transportationProvidedBy:
        type: String
        optional: true
        label: "Transportation will be provided by"
    transportationPaidBy:
        type: String
        optional: true
        label: "Transportation will be paid for by"

    personEnrollingChild:
        type: String
        optional: true
        label: "Individual responsible for enrolling child in school"

    teamDisagreesWithBID:
        type: Boolean
        optional: true
        label: "Team disagress on the best interest determination for the child"
    
    


@BID.reasonsForChange = [
    "Child's permanency plan"
    "Parents/Custodians recommend change"
    "Commute too long"
    "Negative environment at current school"
    "Short time at current school"
    "Safety Issues"
    "New school has positive factors (social, emotional, academic, special needs)"
]

@BID.considerations = [
        key: "childBelief"
        label: "The child believes that remaining in their current school is in their best interest." 
        helpBlock: ["""Consider social interactions,bullying, privacy issues, academics, extracurricular activities."""]
    ,
        key: "parentsBelief"
        label: "The parents/prior custodians believe that remaining in the current school is in the child’s best interest."
    ,
        key: "distance"
        label: "The distance to their current school will be appropriate for a daily commute."
    ,
        key: "longTime"
        label: "The child has attended the current school for a long time or is attached to the school."
        helpBlock: ["""Consider incudes the child’s ties to his or her current school, including 
            significant relationships and involvement in extracurricular activities."""]
    ,
        key: "saftey"
        label: "Safety considerations favor remaining in the current school."
    ,
        key: "remainInSchoolSocial"
        label: "Remaining in the same school will positively impact the child’s social, emotional, and/or behavioral well-being."
        helpBlock: [
            """The effects of trauma on learning including attention, concentration, mood, interpersonal trust, 
            and communication. A child who has experienced trauma can benefit immensely from remaining in their same classroom and school, 
            even when they move to a new home or a new part of town."""
            ,
            "Where do the child’s siblings attend school?"]
    ,
        key: "remainInSchoolAcademics"
        label: "Remaining in the same school will positively impact the child’s academics."
        helpBlock: ["""Consider how the child is performing academically in the current school and the child’s 
            academic/career goals. Also, students on average lose 6 months of academic progress for each school change."""]
    ,
        key: "permanency"
        label: """The child’s permanency goal, plan and expected date for achieving the permanency 
            (reunification, guardianship, or adoption) support remaining in their current school placement."""
        helpBlock: ["""DCF is required to place a child with a relative when appropriate. 
            This factor may override a child remaining in their current school."""
            ,
            "The initial permanency goal for most children is to be reunited with their primary parents."]
]


@BID.documentsUsed = [
    "Report Card"
    "Progress Reports"
    "Achievement Data  (test scores)"
    "Attendance Data" 
    "IEP"
    "504 Plan" 
    "Coordinated Services Plan (or Act 264 Plan)"
    "Emails or Correspondences from Individuals"
    "Other"
]

@BID.simpleSchema = new SimpleSchema(BID.schema)


# MOU
@MOU = {}

@MOU.schema =
    schoolDistrict:
        type: String
        optional: true
        label: "Name of School District"
    superintendentAddress:
        type: String
        optional: true
        label: "Address of Superintendent's Office"
    dataOfCustody:
        type: Date
        optional: true
        label: "Date of custody"
    resourceFamilyName:
        type: String
        optional: true
        label: "Name of Resource Family"
    resourceFamilyAddress:
        type: String
        optional: true
        label: "Resource Family Address"
    mothersName:
        type: String
        optional: true
        label: "Mother's Name"
    fathersName:
        type: String
        optional: true
        label: "Father's Name"
    mothersTown:
        type: String
        optional: true
        label: "Mother's Town"
    fathersTown:
        type: String
        optional: true
        label: "Father's Town"

@MOU.simpleSchema = new SimpleSchema(@MOU.schema)


@CaseSchema =
    name:
        type: String
        unique: true
    dcfId:
        type:String
    age:
        type: Number
        min: 0
    sex:
        type: String
        allowedValues: ["male", "female"]
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
    picture:
        type: Object    # Does not work...  seems to get yanked by collection2
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
        theCase = _.extend(_.pick(caseAttributes, "name", "sex", "age", "urgent", "location", "dcfId"),
            userId: user._id
            lastModifierId: user._id
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

        try   
            caseId = Cases.insert(theCase)
        catch error
            console.log("Error on new case insert", error, Cases, Cases.simpleSchema().namedContext?().invalidKeys?())
            result =
                error: 
                    reason: "Error on new case insert"
                    invalidKeys: Cases.simpleSchema().namedContext().invalidKeys()
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

            message.message = "Case #{caseTag.tag} created by #{user.tag}"

            try
                Messages.insert(message)
                updateCommentsCounts(message)
            catch error
                console.log("Error creating message on case insert", error)
          
        caseId      
            
    updateCase: (caseId, caseAttributes, type) ->
        user = Meteor.user()
        
        # ensure the user is logged in
        throw new Meteor.Error(401, "You need to login to create BIDs") unless user

        omits = ["author", "userId", "submitted", "commentsCount", "_id", "contactName", "contactNumber"]
        theCase = _.extend(_.omit(caseAttributes, omits),
            modified: new Date().getTime()
            lastModifierId: user._id
        )

        if not theCase.contact
            theCase.contact = {}

        if caseAttributes.contactName?
            theCase.contact.name = caseAttributes.contactName

        if caseAttributes.contactNumber?
            theCase.contact.number = caseAttributes.contactNumber
        
        switch type
                when 'BID'
                    if theCase.BID?
                        invalidKeys = []
                        for key in ["childId", "grade"]
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

                when "MOU"
                    if theCase.MOU?
                        invalidKeys = []
                        for key in ["schoolDistrict", "dataOfCustody"]
                            console.log("Check", key, MOU.schema[key])
                            if not theCase.MOU[key] or theCase.MOU[key] is ''
                                invalidKeys.push
                                    message: "#{MOU.schema[key].label} is required"
                                    name: key

                        if invalidKeys.length > 0
                            result =
                                error:
                                    reason: "Error on MOU update"
                                    invalidKeys: invalidKeys
                            return result

                else
                    type = 'case'
                    theCase = massageFormData(theCase, CaseSchema)

        console.log("Update Case", caseId, theCase)
        try
            rtn = Cases.update 
                _id: caseId
            ,
                $set: theCase
        catch error
            console.log("Error on new case update", error, Cases.simpleSchema().namedContext?().invalidKeys?())
            result =
                error: 
                    reason: "Error on case update"
                    invalidKeys: Cases.simpleSchema().namedContext().invalidKeys()
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

            try
                Messages.insert(message)
                updateCommentsCounts(message)
            catch error
                console.log("Error creating message on case update", error)



