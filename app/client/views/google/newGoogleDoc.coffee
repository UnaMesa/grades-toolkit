

Template.newGoogleDoc.rendered = ->
    console.log("googleDocTest renderd")

Template.newGoogleDoc.events
    "submit form": (e) ->
        e.preventDefault()

        doc =
            title: $(e.target).find("[name=documentTitle]").val()
            body: $(e.target).find("[name=documentBody]").val()

        console.log("create new doc", doc)

        Meteor.call "newGoogleDoc", doc, (error, id) ->
            if error
                # Display error to the user
                CoffeeErrors.throw(error.reason)
            else
                CoffeeErrors.success("Created new doc")            
                Router.go("googleDocs")
                # Go somewhere to look at the document


                