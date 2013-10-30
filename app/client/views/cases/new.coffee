
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
                newCase[elm] = 'off'

        console.log("new case", newCase)

        if not newCase.name
            CoffeeAlerts.error("You need fill in the name!")
            $("[name=name]").parent().addClass('has-error')
            window.scrollTo(0, 1)
            return

        Meteor.call "newCase", newCase, (error, id) ->
            if error
                # Display error to the user
                CoffeeAlerts.error(error.reason)
            else
                CoffeeAlerts.success("Created Case")
                # TODO: Go to the Document            
                Router.go("cases")
                