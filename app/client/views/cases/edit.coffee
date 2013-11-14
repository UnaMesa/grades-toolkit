
Template.editCase.events
    "click #cancel": (e) ->
        e.preventDefault()
        Router.go "viewCase",
            _id: Session.get('currentRecordId')

    "submit form": (e) ->
        e.preventDefault()
        
        CoffeeAlerts.clearSeen()
        $(".has-error").removeClass('has-error')

        updatedCase = $('form').serializeObject()
    
        if not updatedCase.sex?
            updatedCase.sex = "female"
    
        # Must check for false checkboxes
        #for elm in ['isMale', 'urgent']
        #    if not newCase[elm]?
        #        newCase[elm] = false

        Meteor.call "updateCase", Session.get('currentRecordId'), updatedCase, (error, result) ->
            if error
                # Display error to the user
                #console.log("Call CoffeeAlerts", error)
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
                CoffeeAlerts.success("Case Updated")
                # TODO: Go to the Document
                console.log("Update Case", result)            
                Router.go "viewCase",
                    _id: Session.get('currentRecordId')
                
