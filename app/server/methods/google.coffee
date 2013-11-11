#
# Google Methods
#
#  Note:  I could not get the googleapi npm to work.  Kept returning "invalid_grant" - TEP
#

getAccessToken = ->
    user = Meteor.user()
    console.log("Get Auth for User", user)
    
    # ensure the user is logged in
    throw new Meteor.Error(401, "You need to be logged in to create docs")  unless user
  
    user.services?.google?.accessToken


getAuth = ->
    user = Meteor.user()
    console.log("Get Auth for User", user)
    
    # ensure the user is logged in
    throw new Meteor.Error(401, "You need to be logged in to create docs")  unless user
  
    # Make sure we have a valid access token
    if not user.services?.google?.accessToken?
        throw new Meteor.Error(452, "Could not get tokens")

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
        access_token:  user.services.google.accessToken
        refresh_token: user.services.google.refreshToken

    console.log("auth", auth)
    auth


Meteor.methods

    #
    #  Server based New doc create
    #    Not working!!!  Using the client side instead (sync issues?)
    #
    newGoogleDoc: (doc, callback) ->
        
        # ensure the doc has a title
        throw new Meteor.Error(422, "Please fill in a document title") unless doc?.title?
        
        auth = getAuth()

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


    googleGetDocInfo: (fileId) ->
        console.log("googleDocTest Called", fileId)

        # ensure the doc has a title
        throw new Meteor.Error(422, "No File ID") unless fileId?
        
        auth = getAuth()

        GoogleApi.discover('drive', 'v2').execute (error, client) ->

            if error
                console.log("Google API error", error)
                throw new Meteor.Error(452, "Google API error" )

            console.log("Google client", client)
            
            client.drive.files.get(
                'fileId': fileId
            ).withAuthClient(auth).execute (err, result) ->
                console.log("error:", err, "inserted:", result?.id)
                if err
                    console.log("Google doc insert error", err)
                    throw new Meteor.Error(455, "Error creating doc")
                console.log("googleDocTest", result)
                result

    googleFetchDoc: (file) ->
        console.log("googleFetchDoc", file)
        # ensure the doc has a title
        throw new Meteor.Error(422, "No File") unless file?

        if file.downloadUrl
            url = file.downloadUrl
        else if file.exportLinks?['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
            url = file.exportLinks?['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
        #else if file.exportLinks?['application/x-vnd.oasis.opendocument.spreadsheet']
        #    url = file.exportLinks?['application/x-vnd.oasis.opendocument.spreadsheet']

        throw new Meteor.Error(422, "No valid download link") unless url?

        if token = getAccessToken()

            console.log('token', token)

            result = HTTP.get url, 
                headers:
                    'Authorization': 'Bearer ' + token

            console.log('result')
            console.log(result)
            console.log('result end')

            xlsx = XLSX.read result.content

            console.log(xlsx)

            xlsx






