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

refreshGoogleAccessToken = ->
    user = Meteor.user()
       
    throw Meteor.Error(401, "You need to be logged in to have access")  unless user

    console.log("refreshGoogleAccessToken", user?.services?.google)
    
    throw Meteor.Error(401, "No Refresh Token") unless user.services?.google?.refreshToken?
    
    loginServiceConfig = Accounts.loginServiceConfiguration.findOne
        service: "google"

    url = 'https://accounts.google.com/o/oauth2/token'
    
    requestBody = 
        "refresh_token=#{user.services.google.refreshToken}" +
        "&client_id=#{loginServiceConfig.clientId}" +
        "&client_secret=#{loginServiceConfig.secret}" +
        "&grant_type=refresh_token"

    result = Meteor.http.post url,
        params:
          'client_id': loginServiceConfig.clientId
          'client_secret': loginServiceConfig.secret
          'refresh_token': user.services.google.refreshToken
          'grant_type': 'refresh_token'
        
    if result.statusCode is 200 and result.data?.access_token?
        console.log("Update Token")
        Meteor.users.update Meteor.userId(),
            $set: 
                "services.google.accessToken": result.data.access_token
                'services.google.expiresAt': (+new Date) + (1000 * result.data.expires_in)
        
        result.data.access_token
    else
        console.log("Google refresh token failed", result)
        throw Meteor.Error(500, "No New Token")


Meteor.methods

    refreshGoogleAccessToken: ->
        refreshGoogleAccessToken()
        

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






