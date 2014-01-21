
saveBid = (generateForm = false, bidOverrides = {}) ->
    CoffeeAlerts.clearSeen()
    $(".has-error").removeClass('has-error')

    if not user = Meteor.user()
        @render("accessDenied")
        return

    theBid = $('form').serializeObject()

    # Get Used Documents Checkboxes
    theBid.documentsUsed = []
    documentsUsedForBid = $(".documentsUsedForBid")
    for documentUsedForBid in documentsUsedForBid
        if $(documentUsedForBid).is(':checked')
            theBid.documentsUsed.push($(documentUsedForBid).attr('key'))

    theBid.bidAttendees = Session.get("bidAttendees")
    
    # Get the Considerations
    considerations = []
    for consideration in BID.considerations
        considerations.push
            key: consideration.key
            yesNo: $("[name=#{consideration.key}_yesNo]:checked").val()
            factors: $("##{consideration.key}_factors").val()

    theBid.considerations = considerations

    _.extend(theBid, bidOverrides) 
    
    if not theBid.childId or theBid.childId is ''
        theBid.childId = @tag

    updatedCase =
        BID: theBid

    console.log("UpdateCase", Session.get('currentRecordId'), updatedCase)
    
    Meteor.call "updateCase", Session.get('currentRecordId'), updatedCase, 'BID', (error, result) ->
        if error
            # Display error to the user
            CoffeeAlerts.error(error.reason)
        else if result?.error?
            if result.error.invalidKeys.length > 0
                for invalidKey in result.error.invalidKeys
                    CoffeeAlerts.error(invalidKey.message)
                    $("[name=#{invalidKey.name}]").parent().addClass('has-error')
            else
                CoffeeAlerts.error(error.reason)
            window.scrollTo(0, 0)
        else
            if generateForm
                #CoffeeAlerts.success("Created Bid")
            
                # TODO: Go to the Document            
                Router.go(generateForm, {_id: Session.get('currentRecordId')})

                # Write it to Google Docs
                # Cases/Name/BID.txt


#Template.bid.created = ->
    

Template.bid.rendered = ->
    #$(".make-switch").bootstrapSwitch()
    console.log("Bid Rendered: Schema", BID.schema)


Template.bid.helpers
    bidDate: ->
        if @BID?.date?
            moment(@BID.date).format('LL')

    stayAtCurrentSchool: ->
        @BID.teamRecommendation is 'stayAtCurrentSchool'

    
Template.bid.events
    "click #cancel": (e) ->
        e.preventDefault()
        Router.go("viewCase")

    "submit form": (e) ->
        e.preventDefault()
        e.stopPropagation()
        console.log("submit")
        false

    # TODO Add in writing to database on a field update (switch focus)
    "click #save-bid": (e) ->
        e.preventDefault()
        saveBid("viewCase")

    "click #generate-bid": (e) ->
        e.preventDefault()
        saveBid("generatedBid")

    "click #generate-mou": (e) ->
        e.preventDefault()
        saveBid("mou")

    
Template.bidDocumentation.rendered = ->
    #$(".make-switch").bootstrapSwitch()

Template.bidDocumentation.helpers 

    boolValues: ->
        vals = []
        for key, val of BID.schema
            if val.type is Boolean and key not in ['stayInCurrentSchool']
                data =
                    'varName': key
                    'description': val.label
                if @BID?[data.varName]
                    data.value = "checked"
                vals.push(data)
        vals

    reasonsForChangeSelect: ->
        vals = []
        for val in BID.reasonsForChange
             data =
                 key: val
             if @BID?.reasonsForChange and val in @BID.reasonsForChange
                 data.selected = "selected"
             vals.push(data)
        vals

    documentsUsedForBid: ->
        vals = []
        for val in BID.documentsUsed
             data =
                 key: val
             if @BID?.documentsUsed and val in @BID.documentsUsed
                 data.checked = "checked"
             vals.push(data)
        vals

Template.bidMeetingAttendees.helpers
    attendees: ->
        if @BID?
            if not @BID.bidAttendees
                @BID.bidAttendees = []
            Session.set("bidAttendees", @BID.bidAttendees)
            theAttendees = @BID.bidAttendees #Session.get("bidAttendees")
            index = 0
            if theAttendees?
                for attendee in theAttendees
                    attendee.index = index
                    index++
            theAttendees

Template.bidMeetingAttendees.events
    "click #addAttendee": (e) ->
        e.preventDefault()
        if $("#newAttendeeName").val()
            if $("#newAttendeeRole").val() is 'Role'
                CoffeeAlerts.error("Select a Role for the Attendee")
                $("#newAttendeeRole").parent().addClass('has-error')
            else
                bidAttendees = Session.get("bidAttendees")
                if not bidAttendees
                    bidAttendees = []
                bidAttendees.push
                    name: $("#newAttendeeName").val()
                    role: $("#newAttendeeRole").val()
                    contactInfo: $("#newAttendeeContactInfo").val()
                #Session.set("bidAttendees", theAttendees)
                $("#newAttendeeName").val('')
                $("#newAttendeeContactInfo").val('')
                $("#newAttendeeRole").val('Role')
                saveBid false,
                    bidAttendees: bidAttendees

    "click .removeAttendee": (e) ->
        e.preventDefault()
        console.log("remove Attendee", @)
        bidAttendees = Session.get("bidAttendees")
        bidAttendees.splice(@index, 1)
        saveBid false,
            bidAttendees: bidAttendees


Template.bidConsiderations.rendered = ->
    $('[rel="popover"]').popover()

Template.bidConsiderations.helpers
    considerations: ->
        considerations = []
        for consideration in BID.considerations
            data = _.clone(consideration)
            if data.helpBlock
                data.helpText = ''
                for help in data.helpBlock
                    data.helpText +=  '&bull; ' + help
            if @BID?.considerations
                for theCons in @BID.considerations
                    if theCons.key is data.key
                        data.factors = theCons.factors
                        switch theCons.yesNo
                            when 'yes'
                                data.yes = "checked=checked"
                            when 'no'
                                data.no = "checked=checked"
                        break
            considerations.push(data)
        console.log("considerations", considerations)
        considerations

bidSummarySetUp = ->
   switch $('[name=teamRecommendation]:checked').val()
        when 'stayAtCurrentSchool'
            $('[for="schoolToAttend"]').html('Name of Current School')
            $('#school-to-attend').removeClass("hidden")
            $('#su-sd').removeClass("hidden")
            $('#personEnrollingChild').addClass("hidden")
            $('#transportationProvidedBy').removeClass("hidden")
            $('#transportationPaidBy').removeClass("hidden")
            $('#teamDisagreeNextSteps').addClass("hidden")
            $("#generate-mou").removeClass("hidden")
        when 'moveToNewSchool'
            $('[for="schoolToAttend"]').html('Name of New School')
            $('#school-to-attend').removeClass("hidden")
            $('#su-sd').removeClass("hidden")
            $('#transportationProvidedBy').addClass("hidden")
            $('#transportationPaidBy').addClass("hidden")
            $('#personEnrollingChild').removeClass("hidden")
            $('#teamDisagreeNextSteps').addClass("hidden")
            $("#generate-mou").addClass("hidden")
        when 'teamDisagrees'
            $('[for="schoolToAttend"]').html('Name of School')
            $('#school-to-attend').addClass("hidden")
            $('#su-sd').addClass("hidden")
            $('#personEnrollingChild').addClass("hidden")
            $('#transportationProvidedBy').addClass("hidden")
            $('#transportationPaidBy').addClass("hidden")
            $('#teamDisagreeNextSteps').removeClass("hidden")
            $("#generate-mou").addClass("hidden")

Template.bidSummary.rendered = ->
    bidSummarySetUp()

Template.bidSummary.helpers
    
    stayAtCurrentSchool: ->
        @BID.teamRecommendation is 'stayAtCurrentSchool'
        
    moveToNewSchool: ->
        @BID.teamRecommendation is 'moveToNewSchool'

    teamDisagrees: ->
        @BID.teamRecommendation is 'teamDisagrees'

Template.bidSummary.events
    "change [name=teamRecommendation]": (e) ->
        bidSummarySetUp()
        