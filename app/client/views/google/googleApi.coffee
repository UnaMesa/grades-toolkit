
#
#  Object to handle Google Drive API requests
#

@gDrive =

    authorized: false
    _currentLikeCountListeners: null
    _fileList: []
    _gettingList: false
    _callBack: null
    dirty: false

    init: (callBack) ->
        gDrive._callBack = callBack
        if not gDrive._currentLikeCountListeners?
            gDrive._currentLikeCountListeners = new Deps.Dependency()

        Meteor.defer ->
            console.log("init")
            _.once(gapi.client.load('drive', 'v2', gDrive.afterLoad))
    
    fileList: ->
        gDrive._currentLikeCountListeners.depend()
        gDrive._fileList


    _appendToFileList: (newFiles) ->
        gDrive._fileList = gDrive._fileList.concat(newFiles)
        gDrive._currentLikeCountListeners.changed()

    removeFileFromList: (fileId) ->
        newList = []
        for element in gDrive._fileList
            if element.id isnt fileId
                newList.push(element)
        gDrive._fileList = newList
        gDrive._currentLikeCountListeners.changed()

    afterLoad: ->
        gDrive.checkAuth()

    checkAuth: ->
        if not gDrive.authorized
            console.log("checkAuth")
            Meteor.defer ->
                gapi.auth.authorize
                    'client_id': "543454987250.apps.googleusercontent.com"
                    'scope': "https://www.googleapis.com/auth/drive.file"
                    'immediate': true
                , (authResult) ->
                    if authResult and not authResult.error
                        gDrive.authorized = true
                        console.log(authResult)
                        if gDrive._callBack
                            gDrive._callBack()
                    else
                        CoffeeError.throw("Authorization Failed")
            

    getFileList: ->
        if gDrive.authorized and not gDrive._gettingList
            gDrive._gettingList = true
            console.log("getFileList")
            initialRequest = gapi.client.drive.files.list()
            console.log("got initial request")
            gDrive._fileList = []
            gDrive.retrievePageOfFiles(initialRequest)


    retrievePageOfFiles: (request) ->
        console.log("retrievePageOfFiles")
        request.execute (resp) ->
            gDrive._appendToFileList(resp.items)
            nextPageToken = resp.nextPageToken
            if nextPageToken
                request = gapi.client.drive.files.list(pageToken: nextPageToken)
                gDrive.retrievePageOfFiles(request)
            else
                # Done
                console.log(gDrive._fileList)
                gDrive._gettingList = false
                
