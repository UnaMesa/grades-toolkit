
saveBid = (generateBid = false, bidOverrides = {}) ->
    CoffeeAlerts.clearSeen()
    $(".has-error").removeClass('has-error')

    if not user = Meteor.user()
        @render("accessDenied")
        return

    theBid = $('form').serializeObject()

    theBid.documentsUsed = []
    # Get Checkboxes
    documentsUsedForBid = $(".documentsUsedForBid")
    for documentUsedForBid in documentsUsedForBid
        if $(documentUsedForBid).is(':checked')
            theBid.documentsUsed.push($(documentUsedForBid).attr('key'))

    theBid.bidAttendees = Session.get("bidAttendees")
    
    considerations = []
    for consideration in BID.considerations
        console.log("consideration", consideration.key, "##{consideration.key}_yesNo", $("##{consideration.key}_yesNo").val())
        considerations.push
            key: consideration.key
            yesNo: ($("##{consideration.key}_yesNo").attr("checked") is 'checked')
            factors: $("##{consideration.key}_factors").val()

    theBid.considerations = considerations

    _.extend(theBid, bidOverrides) 
    
    # Must check for false checkboxes
    
    ###
    for key, val of BID.schema
        if key in ['documentsUsed', 'reasonsForChange']
            if not typeIsArray theBid[key]
                theBid[key] = [theBid[key]]
    ###

    # Since we are writing to the Case record these are already there
    #for elm in ['name', 'age', 'location']
    #    newBid[elm] = @[elm]

    #newBid.submitter = user.profile.name # ?

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
            if (generateBid)
                CoffeeAlerts.success("Created Bid")
            
                # TODO: Go to the Document            
                Router.go("viewCase", {_id: Session.get('currentRecordId')})

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

    "click #generate-bid": (e) ->
        e.preventDefault()
        saveBid(true)

    
Template.bidDocumentation.rendered = ->
    $(".make-switch").bootstrapSwitch()

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
            if @BID?.considerations
                for theCons in @BID.considerations
                    if theCons.key is data.key
                        data.factors = theCons.factors
                        if theCons.yesNo
                            data.value = "checked=checked"
                        else 
                            data.value = ''
                        break
            considerations.push(data)
        console.log("considerations", considerations)
        considerations

        

Template.bidSummary.helpers
    remainInSchool: ->
        data = 
            'varName': 'stayInCurrentSchool'
            'description': "Remain in current school"
        if @BID?[data.varName]
            data.value = "checked"
        data
