
#
#  Object to handle Google Drive API requests
#

@gDrive =

    _authorized: false

    _loading: false
    
    _callBack: null

    _currentFileListListeners: null

    _fileList: []

    _gettingList: false

    dirty: false

    init: ->
        console.log("gDrive.init")
        gDrive.load()

    load: ->
        console.log("gDrive.load")
        if not gapi.client?
            # If this starts up before the Google API has loaded
            console.log("Google API has not loaded....")
            Meteor.setTimeout(gDrive.load, 200)
        else
            if not gDrive._loading and not gapi.client.drive?
                gDrive._loading = true
                gapi.client.load('drive', 'v2', gDrive.afterLoad)

    afterLoad: ->
        console.log("gapi.client.drive loaded", gapi.client.drive)
        gDrive._loading = false
        if Meteor.user()
            gDrive.checkAuth()

    checkAuth: ->
        if not gDrive.authorized
            console.log("checkAuth")
            #Meteor.defer ->
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
    
    call: (callBack) ->
        gDrive._callBack = callBack
        if not gapi.client?.drive?
            console.log("gapi.client.drive is not loaded", gapi.client)
            gDrive.load()
        else
            gDrive.checkAuth()
    
    fileList: ->
        console.log("fileList")
        if not gDrive._currentFileListListeners?
            gDrive._currentFileListListeners = new Deps.Dependency()
        gDrive._currentFileListListeners.depend()
        gDrive._fileList


    _appendToFileList: (newFiles) ->
        gDrive._fileList = gDrive._fileList.concat(newFiles)
        gDrive._currentFileListListeners.changed()

    removeFileFromList: (fileId) ->
        newList = []
        for element in gDrive._fileList
            if element.id isnt fileId
                newList.push(element)
        gDrive._fileList = newList
        gDrive._currentFileListListeners.changed()
    
    getFileList: ->
        if gDrive.authorized and not gDrive._gettingList
            gDrive._gettingList = true
            console.log("getFileList")
            gDrive._callBack = null
            if not gDrive._currentFileListListeners?
                gDrive._currentFileListtListeners = new Deps.Dependency()
            initialRequest = gapi.client.drive.files.list()
            console.log("Initial request")
            gDrive._fileList = []
            gDrive._retrievePageOfFiles(initialRequest)


    _retrievePageOfFiles: (request) ->
        console.log("_retrievePageOfFiles")
        request.execute (resp) ->
            gDrive._appendToFileList(resp.items)
            nextPageToken = resp.nextPageToken
            if nextPageToken
                request = gapi.client.drive.files.list(pageToken: nextPageToken)
                gDrive._retrievePageOfFiles(request)
            else
                # Done
                console.log("List Complete", gDrive._fileList)
                gDrive._gettingList = false
                
