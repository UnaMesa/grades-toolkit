#
# Methods
#
#  Note:  I could not get the googleapi npm to work.  Kept returning "invalid_grant" - TEP
#

Meteor.methods
    newGoogleDoc: (doc, callback) ->
        user = Meteor.user()
        console.log("Create a new google doc", doc, user)

        # ensure the user is logged in
        throw new Meteor.Error(401, "You need to be logged in to create docs")  unless user
  
        # ensure the doc has a title
        throw new Meteor.Error(422, "Please fill in a document title") unless doc?.title?
  
        # Make sure we have a valid access token
        if not user.services?.google?.accessToken?
            throw new Meteor.Error(452, "Could not get accessToken")

        # Create auth object
        gCreds = Accounts.loginServiceConfiguration.findOne({"service" : "google"})
        console.log("Google Credentials", gCreds)
        if not gCreds
            throw new Meteor.Error(400, "Google authorization failed")

        redirectUrl = "http://localhost:3000/_oauth/google?close"

        auth = new GoogleApi.OAuth2Client(gCreds.clientId, gCreds.secret, redirectUrl)
        if not auth
            throw new Meteor.Error(452, "Google authorization failed")

        auth.credentials =
            access_token: user.services.google.accessToken

        console.log("auth", auth)
        
        GoogleApi.discover('drive', 'v2').execute (error, client) ->

            if error
                console.log("Google API error", error)
                throw new Meteor.Error(452, "Google API error" )

            console.log("Google client", client)
            client.drive.files.insert(
                title: doc.title
                mimeType: "text/plain"
            ).withMedia("text/plain", doc.body).withAuthClient(auth).execute (err, result) ->
                console.log("error:", err, "inserted:", result?.id)
                if err
                    console.log("Google doc insert error", err)
                    throw new Meteor.Error(455, "Error creating doc")
                result


