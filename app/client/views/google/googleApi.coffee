
#
#  Object to handle Google Drive API requests
#

@gDrive =

    _authorized: false
    _authorizing: false
    _userInitiatedAuth: false
    _immediate: true
    _refreshingToken: false

    _loading: false
    
    _callBack: null

    _currentFileListListeners: null
    _currentStateListeners: null

    _fileList: []

    _gettingFileList: false

    fileListLoaded: false

    _path: [
        id:    "root"
        title: "My Drive"
        last:  true
    ]

    topDirectory: null
    deleteOk: false
    testingOk: false

    userDeclined: false

    init: ->
        #console.log("gDrive.init")
        if not gDrive._currentFileListListeners?
            gDrive._currentFileListListeners = new Deps.Dependency()
        if not gDrive._currentStateListeners?
            gDrive._currentStateListeners = new Deps.Dependency()
        gDrive.load()

    reset: ->
        gDrive.topDirectory = null
        gDrive.deleteOk = false
        gDrive.testingOk = false
        gDrive._path = [
            id:    "root"
            title: "My Drive"
            last:  true
        ]

    reAuthorize: ->
        gDrive._authorized = false
        gDrive._authorizing = false
        gDrive._immediate = true
        gDrive._refreshingToken = false

    fullReset: ->
        gDrive.reAuthorize()        
        gDrive.reset()

    userInitiatedAuth: ->
        gDrive.reAuthorize()
        gDrive._userInitiatedAuth = true
        gDrive._currentStateListeners.changed()

    load: ->
        console.log("gDrive.load")
        if not gapi.client?
            # If this starts up before the Google API has loaded
            console.log("Google API has not loaded....")
            Meteor.setTimeout(gDrive.load, 200)
        else
            if not gDrive._loading and not gapi.client.drive?
                gDrive._loading = true
                gDrive._currentStateListeners.changed()
                gapi.client.load('drive', 'v2', gDrive.afterLoad)

    afterLoad: ->
        console.log("gapi.client.drive loaded", gapi.client.drive)
        gDrive._loading = false
        gDrive._currentStateListeners.changed()
        if user = Meteor.user()
            gDrive.checkAuth()


    authorized: ->
        if not gDrive._currentStateListeners?.depend?
            gDrive.init()
        gDrive._currentStateListeners.depend()
        gDrive._authorized

    authorizing: ->
        if not gDrive._currentStateListeners?.depend?
            gDrive.init()
        gDrive._currentStateListeners.depend()
        gDrive._authorizing && gDrive._userInitiatedAuth

    loading: ->
        gDrive._currentStateListeners.depend()
        gDrive._loading

    #
    # See: https://developers.google.com/drive/auth/web-client
    #
    checkAuth: ->
        console.log("checkAuth called", gDrive._immediate)
        if not gDrive._authorized and not gDrive._authorizing
            if user = Meteor.user()
                console.log("checkAuth", user)
                # TODO: Add checks to keep the token in sync!!!
                if user.services?.google?.accessToken?
                    console.log("Doing authorization transfer", user, user.services?.google?.accessToken)
                    expiresAt = moment(user.services.google.expiresAt)
                    expiresIn = expiresAt.diff(moment(), 'seconds')
                    gapi.auth.setToken
                        access_token: user.services.google.accessToken
                        expires_in: expiresIn
                    gDrive._authorized = true
                    gDrive._currentStateListeners.changed()
                    if gDrive._callBack?
                        gDrive._callBack()

            return
            #
            #  TODO: Check for popup blocking for this causes havoc!!!
            #
            console.log("checkAuth", gDrive._immediate)
            gDrive._authorizing = true
            gDrive._currentStateListeners.changed()
            #gDrive._currentFileListListeners.changed()
            gapi.auth.authorize
                'client_id': "543454987250.apps.googleusercontent.com"
                #'scope': "https://www.googleapis.com/auth/drive"
                'scope': googleScopes
                'immediate': gDrive._immediate # Setting the immediate parameter to true in the call to 
                                               # gapi.auth.authorize() ensures the user only sees a 
                                               # permissions dialog if they have not previously authorized 
                                               # your application.
            , (authResult) ->
                console.log("Google Auth Callback", authResult, gDrive.immediate)
                gDrive._authorizing = false
                gDrive._userInitiatedAuth = false
                if authResult and not authResult.error
                    gDrive._authorized = true
                    if gDrive._callBack
                        gDrive._callBack()
                else if (gDrive._immediate)
                    gDrive._immediate = false
                    return gDrive.checkAuth(false)
                else 
                    if authResult?.error?
                        console.log("Google Auth Error", authResult.error)
                    else
                        console.log("Google No Auth Return", authResult)
                    CoffeeAlerts.error("Google Authorization Failed  #{authResult?.error?.message}")
                gDrive._currentStateListeners.changed()
        else if gDrive._callBack?
            gDrive._callBack()

    
    call: (callBack) ->
        gDrive._callBack = callBack
        if not gapi.client?.drive?
            console.log("gapi.client.drive is not loaded", gapi.client)
            gDrive.load()
        else
            gDrive.checkAuth()
    
    path: ->
        gDrive._currentFileListListeners.depend()
        gDrive._path

    gotoDirectory: (file) ->
        gDrive._path[gDrive._path.length-1].last = false
        gDrive._path.push
            id: file.id
            title: file.title
            last: true
        gDrive._currentFileListListeners.changed()

    uptoDirectory: (dir) ->
        while dir isnt gDrive._path[gDrive._path.length-1].id
            gDrive._path.pop()
    
        gDrive._path[gDrive._path.length-1].last = true
        gDrive._currentFileListListeners.changed()

    currentDirectory: ->
        gDrive._path[gDrive._path.length-1]

    fileList: ->
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
    
    gettingFileList: ->
        gDrive._currentStateListeners.depend()
        gDrive._gettingFileList


    getFileList: ->
        if gDrive._authorized and not gDrive._gettingFileList
            gDrive._gettingFileList = true
            gDrive._currentStateListeners.changed()
            console.log("getFileList")
            gDrive._callBack = null
            initialRequest = gapi.client.drive.files.list()
            gDrive._fileList = []
            gDrive._retrievePageOfFiles(initialRequest)


    _retrievePageOfFiles: (request) ->
        request.execute (resp) ->
            if not resp.error
                gDrive._appendToFileList(resp.items)
                nextPageToken = resp.nextPageToken
                if nextPageToken
                    request = gapi.client.drive.files.list(pageToken: nextPageToken)
                    gDrive._retrievePageOfFiles(request)
                else
                    # Done
                    console.log("List Complete, count:", gDrive._fileList.length)
                    #console.log("List Complete", gDrive._fileList)
                    
                    if gDrive.topDirectory?
                        gDrive.setTopDirectory()

                    gDrive._gettingFileList = false
                    gDrive.fileListLoaded = true
                    gDrive._currentStateListeners.changed()
            else
                # TODO:  Check for 401 and reauthorize/refresh tokens
                console.log('_retrievePageOfFiles Error', resp.error)
                gDrive._appendToFileList(null)
                gDrive._gettingFileList = false
                gDrive.fileListLoaded = true
                gDrive._currentStateListeners.changed()
                if resp.error.code is 401
                    console.log("Google Token may be stale")
                    gDrive._callBack = gDrive.getFileList
                    gDrive._refreshToken()

    _refreshToken: ->
        console.log("ReFresh Token!!!")
        gDrive.reAuthorize()
        gDrive._refreshingToken = true
        Meteor.call "refreshGoogleAccessToken", (error, result) ->
            if error
                console.log("Error getting new token", error, result)
                CoffeeAlerts.error("Could not get new token #{error?.message}")
            else if result
                gDrive._refreshingToken = false
                gDrive.checkAuth()


    setTopDirectory: ->
        gDrive._path = [
            id:    null
            title: "#{gDrive.topDirectory} Directory Not Found"
            last:  true
        ]
        for file in gDrive._fileList
            if file?.mimeType is 'application/vnd.google-apps.folder'
                if file.title is gDrive.topDirectory
                    gDrive._path = [
                        id:    file.id
                        title: gDrive.topDirectory
                        last:  true
                    ]

    getFileListInRootFolder: ->
        gDrive.getFilesInFolder('root')

    getFilesInFolder: (folderId) ->
        if gDrive._authorized and not gDrive._gettingFileList
            gDrive._gettingFileList = true
            gDrive._currentStateListeners.changed()
            console.log("getFileList")
            gDrive._callBack = null
            initialRequest = gapi.client.drive.children.list
                'folderId': folderId
            gDrive._fileList = []
            gDrive._retrievePageOfFilesInFolder(folderId, initialRequest)


    _retrievePageOfFilesInFolder: (folderId, request) ->
        console.log("_retrievePageOfFiles")
        request.execute (resp) ->
            gDrive._appendToFileList(resp.items)
            nextPageToken = resp.nextPageToken
            if nextPageToken
                request = gapi.client.drive.files.list
                    'folderId': folderId
                    pageToken: nextPageToken
                gDrive._retrievePageOfFiles(folderId, request)
            else
                # Done
                console.log("List Complete, count:", gDrive._fileList.length)
                #console.log(gDrive._fileList)
                gDrive._gettingFileList = false
                gDrive.fileListLoaded = true
                gDrive._currentStateListeners.changed()


    getFilesInCurrentFolder: ->
        theFiles = []
        if gDrive._authorized and not gDrive._gettingFileList and gDrive.fileListLoaded
            console.log("Get files in ", gDrive?.currentDirectory?().title)
            for file in gDrive._fileList
                if file?
                    if gDrive.currentDirectory().id is 'root'
                        if file.parents?[0]?.isRoot
                            theFiles.push file
                    else if file.parents?[0]?.id is gDrive.currentDirectory().id
                        theFiles.push file
        theFiles
        

    currentParent: ->
        if gDrive.currentDirectory().id isnt 'root'
            parent =
                id: gDrive.currentDirectory().id
                isRoot: false
                kind: "drive#parentReference"

    findDirectory: (title, parentId) ->
        if not parentId?
            parentId = 'root'
        for file in gDrive._fileList  # non-reactive
            if file.mimeType is 'application/vnd.google-apps.folder' and file.title is title
                if parentId is 'root' and file.parents?[0]?.isRoot
                    return file
                else if file.parents?[0]?.id is parentId
                    return file

    findFile: (title, parentId, type) ->
        if not parentId?
            parentId = 'root'
        for file in gDrive._fileList  # non-reactive
            if file.title is title and (not type? or file.mimeType is type) and file.mimeType isnt 'application/vnd.google-apps.folder'
                if parentId is 'root' and file.parents?[0]?.isRoot
                    return file
                else if file.parents?[0]?.id is parentId
                    return file

    createDirectory: (title, parentId) ->
        if not parentId?
            parentId = 'root'
        if gDrive.findDirectory(title, parentId)
            CoffeeAlerts.warning("Folder exists")
        else
            metadata =
                'title': title
                "parents": [{"id": parentId}]
                'mimeType': 'application/vnd.google-apps.folder'
            request = gapi.client.request        
                'path': '/drive/v2/files'
                'method': 'POST'
                'headers':
                    'Content-Type': 'application/json'
                'body': JSON.stringify(metadata)
            request.execute (newFolder) ->
                if newFolder.error
                    console.log("createDirectory Error",newFolder.error)
                    CoffeeAlerts.error("Could not create folder")
                else
                    console.log("new folder", newFolder, gDrive)
                    gDrive._fileList.unshift(newFolder)
                    gDrive._currentFileListListeners.changed()


    findOrCreateDirectory: (dirPath) ->
        pathParts = _.difference(dirPath.split('/'), [""])
        parentId = 'root'
        for path in pathParts
            if dir = findDirectory(path, parentId)
                parentId = dir.id
            else
                # Create it ??
                return false
        return true

        
    ###
    Download a file's content.

    @param {File} file Drive File instance.
    @param {Function} callback Function to call when the request is complete.
    ###
    downloadFile: (file, callback) ->
        if file.downloadUrl
            accessToken = gapi.auth.getToken().access_token
            xhr = new XMLHttpRequest()
            xhr.open "GET", file.downloadUrl
            xhr.setRequestHeader "Authorization", "Bearer " + accessToken
            xhr.onload = ->
                callback xhr.responseText

            xhr.onerror = ->
                callback null

            xhr.send()
        else
            callback null
        

