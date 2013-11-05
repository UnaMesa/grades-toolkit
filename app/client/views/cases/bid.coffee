

Template.bid.rendered = ->
    $(".make-switch")["bootstrapSwitch"]()


Template.bid.events
    "click #cancel": (e) ->
        e.preventDefault()
        Router.go("viewCase")

    "submit form": (e) ->
        e.preventDefault()

        if not user = Meteor.user()
            @render("accessDenied")
            return


        newBid = $('form').serializeObject()

        for elm in ['name', 'age', 'location']
            newBid[elm] = @[elm]

        newBid.submitter = user.profile.name

        # Must check for false checkboxes
        for elm in ['isMale', 'urgent']
            if not newBid[elm]?
                newBid[elm] = 'off'

        console.log("new BID", newBid, user)

        if not newBid.something
            CoffeeAlerts.error("You need fill in the something!")
            $("[name=something]").parent().addClass('has-error')
            window.scrollTo(0, 1)
            return

        # Write it to Google Docs
        
        # Cases/Name/BID.txt


        # Add messsage to stream
                