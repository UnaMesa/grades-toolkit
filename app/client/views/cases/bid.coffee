
@yesNoAttribures = []

Template.bid.rendered = ->
    $(".make-switch")["bootstrapSwitch"]()
    console.log("Schema", Cases.simpleSchema(), BID.schema)


Template.bid.helpers
    "remainInSchool": ->
        data = 
            'varName': 'stayInCurrentSchool'
            'description': "Remain in current school"
        if @[data.varName]
            data.value = "checked"
        Template.slider(data)

    boolValues: ->
        vals = []
        for key, val of BID.schema
            if val.type is Boolean and key not in ['stayInCurrentSchool']
                data =
                    'varName': key
                    'description': val.label
                if @[data.varName]
                    data.value = "checked"
                vals.push(data)
        vals

    reasonsForChangeSelect: ->
        console.log("reasonsForChange", @reasonsForChange)
        vals = []
        for val in BID.reasonsForChange
             data =
                 key: val
             if @reasonsForChange and val in @reasonsForChange
                 data.selected = "selected"
             vals.push(data)
        console.log("reasonsForChange", vals)
        vals

    documentsUsedSelect: ->
        vals = []
        for val in BID.documentsUsed
             data =
                 key: val
             if @documentsUsed and val in @documentsUsed
                 data.selected = "selected"
             vals.push(data)
        vals


Template.bid.events
    "click #cancel": (e) ->
        e.preventDefault()
        Router.go("viewCase")

    # TODO Add in writing to database on a field update (switch focus)

    "submit form": (e) ->
        e.preventDefault()

        if not user = Meteor.user()
            @render("accessDenied")
            return

        theBid = $('form').serializeObject()

        # Must check for false checkboxes
        for key, val of BID.schema
            #if typeOf(val.type) is 'function'



            switch val.type
                when Boolean
                    if theBid[key] is 'on'
                        theBid[key] = true
                    else
                        theBid[key] = false
                when Date 
                    if theBid[key] is ''
                        delete theBid[key]
                #when [String]
                #    if not typeIsArray theBid[key]
                #        theBid[key] = [theBid[key]]

            if key in ['documentsUsed', 'reasonsForChange']
                if not typeIsArray theBid[key]
                    theBid[key] = [theBid[key]] 


        # Since we are writing to the Case record these are already there
        #for elm in ['name', 'age', 'location']
        #    newBid[elm] = @[elm]

        #newBid.submitter = user.profile.name # ?

        console.log("new BID", theBid, user)

        if not theBid.childId or theBid.childId is ''
            theBid.childId = @tag

        Meteor.call "updateCase", Session.get('currentRecordId'), theBid, (error, result) ->
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
                CoffeeAlerts.success("Created Bid")
                # TODO: Go to the Document            
                Router.go("viewCase", {_id: Session.get('currentRecordId')})

        # Write it to Google Docs
        
        # Cases/Name/BID.txt


        # Add messsage to stream
                