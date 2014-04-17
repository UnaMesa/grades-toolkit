
saveMou = (routeOnSave = false) ->
    CoffeeAlerts.clearSeen()
    $(".has-error").removeClass('has-error')

    if not user = Meteor.user()
        @render("accessDenied")
        return

    theMou = $('form').serializeObject()

    updatedCase =
        MOU: theMou

    console.log("UpdateCase", Session.get('currentRecordId'), updatedCase)
    
    Meteor.call "updateCase", Session.get('currentRecordId'), updatedCase, 'MOU', (error, result) ->
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
            if routeOnSave
        
                switch routeOnSave
                    when 'generatedMou'
                        Meteor.call('generateMou', Session.get('currentRecordId'))
                        newWindow = window.open Router.routes[routeOnSave].path
                            _id: Session.get('currentRecordId')

                        if !newWindow or newWindow.closed or typeof newWindow.closed=='undefined'
                            alert("Pop Up Blocked!  Opening in current window") 
                            Router.go(routeOnSave, {_id: Session.get('currentRecordId')})

                    else
                        CoffeeAlerts.success("Created Mou")
                        Router.go(routeOnSave, {_id: Session.get('currentRecordId')})

                # Write it to Google Docs
                # Cases/Name/BID.txt

Template.mou.helpers

    mouFields: ->
        fields = []
        for key, obj of MOU.schema
            switch obj.type
                when Date
                    type = 'date'
                    placeholder = 'MM/DD/YYYY'
                    value = moment(@MOU?[key]).format('LL')
                else
                    type = 'text'
                    placeholder = obj.label
                    value = @MOU?[key]
            data =
                key: key
                value: value
                label: obj.label
                type: type
                placeholder: placeholder

            if key in ['superintendentAddress', 'resourceFamilyAddress']
                data.textarea = true
            data.required = 'required'
            fields.push data  
        fields


Template.mou.events
    
    "submit form": (e) ->
        e.preventDefault()
        e.stopPropagation()
        console.log("submit")
        false

    "click #save-mou": (e) ->
        e.preventDefault()
        saveMou("viewCase")

    "click #generate-mou": (e) ->
        e.preventDefault()
        saveMou("generatedMou")
