
#
#  Object to handle Google Drive API requests
#

@gDrive =

    _authorized: false
    _authorizing: false
    _userInitiatedAuth: false

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

    init: ->
        console.log("gDrive.init")
        if not gDrive._currentFileListListeners?
            gDrive._currentFileListListeners = new Deps.Dependency()
        if not gDrive._currentStateListeners?
            gDrive._currentStateListeners = new Deps.Dependency()
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
                gDrive._currentStateListeners.changed()
                gapi.client.load('drive', 'v2', gDrive.afterLoad)

    afterLoad: ->
        console.log("gapi.client.drive loaded", gapi.client.drive)
        gDrive._loading = false
        gDrive._currentStateListeners.changed()
        if Meteor.user()
            gDrive.checkAuth()

    authorized: ->
        gDrive._currentStateListeners.depend()
        gDrive._authorized

    authorizing: ->
        gDrive._currentStateListeners.depend()
        gDrive._authorizing && gDrive._userInitiatedAuth

    loading: ->
        gDrive._currentStateListeners.depend()
        gDrive._loading

    userInitiatedAuth: ->
        gDrive._authorizing = false
        gDrive._userInitiatedAuth = true
        gDrive._currentStateListeners.changed()

    checkAuth: ->
        console.log("checkAuth called")
        if not gDrive._authorized and not gDrive._authorizing
            #
            #  TODO: Check for popup blocking for this causes havoc!!!
            #
            console.log("checkAuth")
            gDrive._authorizing = true
            gDrive._currentStateListeners.changed()
            gDrive._currentFileListListeners.changed()
            gapi.auth.authorize
                'client_id': "543454987250.apps.googleusercontent.com"
                #'scope': "https://www.googleapis.com/auth/drive"
                'scope': googleScopes
                'immediate': false
            , (authResult) ->
                gDrive._authorizing = false
                gDrive._userInitiatedAuth = false
                if authResult and not authResult.error
                    gDrive._authorized = true
                    console.log("Google Auth", authResult)
                    if gDrive._callBack
                        gDrive._callBack()

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
            gDrive._appendToFileList(resp.items)
            nextPageToken = resp.nextPageToken
            if nextPageToken
                request = gapi.client.drive.files.list(pageToken: nextPageToken)
                gDrive._retrievePageOfFiles(request)
            else
                # Done
                console.log("List Complete", gDrive._fileList.length)
                #console.log("List Complete", gDrive._fileList)
                
                if gDrive.topDirectory?
                    gDrive.setTopDirectory()

                gDrive._gettingFileList = false
                gDrive.fileListLoaded = true
                gDrive._currentStateListeners.changed()


    setTopDirectory: ->
        gDrive._path = [
            id:    null
            title: "#{gDrive.topDirectory} Directory Not Found"
            last:  true
        ]
        for file in gDrive._fileList
            if file.mimeType is 'application/vnd.google-apps.folder'
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
                console.log("List Complete", gDrive._fileList.length)
                #console.log(gDrive._fileList)
                gDrive._gettingFileList = false
                gDrive.fileListLoaded = true
                gDrive._currentStateListeners.changed()


    getFilesInCurrentFolder: ->
        console.log("Get files in ", gDrive.currentDirectory().title)
        theFiles = []
        for file in gDrive.fileList()
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


    
        

