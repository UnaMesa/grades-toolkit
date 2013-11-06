
Template.newCase.rendered = ->
    $(".make-switch")["bootstrapSwitch"]()


Template.newCase.events
    "click #cancel": (e) ->
        e.preventDefault()
        Router.go("cases")

    "submit form": (e) ->
        e.preventDefault()

        newCase = $('form').serializeObject()
    
        # Must check for false checkboxes
        for elm in ['isMale', 'urgent']
            if not newCase[elm]?
                newCase[elm] = false

        Meteor.call "newCase", newCase, (error, result) ->
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
                CoffeeAlerts.success("Created Case")
                # TODO: Go to the Document            
                Router.go("cases")
                