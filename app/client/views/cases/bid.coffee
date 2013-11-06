
@yesNoAttribures = []

Template.bid.rendered = ->
    $(".make-switch")["bootstrapSwitch"]()
    console.log("Schema", Cases.simpleSchema(), BIDSchema)


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
        for key, val of BIDSchema
            if val.type is Boolean and key not in ['stayInCurrentSchool']
                data =
                    'varName': key
                    'description': val.label
                if @[data.varName]
                    data.value = "checked"
                console.log(data, @)
                vals.push(data)
        console.log("boolValues", vals)
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
        for key, val of BIDSchema
            if val.type is Boolean
                if theBid[key] is 'on'
                    theBid[key] = true
                else
                    theBid[key] = false
            else if val.type is Date 
                if theBid[key] is ''
                    delete theBid[key]

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
                #Router.go("viewCase", {_id: Session.get('currentRecordId')})

        # Write it to Google Docs
        
        # Cases/Name/BID.txt


        # Add messsage to stream
                