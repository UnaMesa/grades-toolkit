
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

    fileListLoaded: false

    dirTree: [
        id:"root"
        title:"root"
    ]

    init: ->
        console.log("gDrive.init")
        if not gDrive._currentFileListListeners?
            gDrive._currentFileListListeners = new Deps.Dependency()
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

    authorized: ->
        gDrive._currentFileListListeners.depend()
        gDrive._authorized;

    checkAuth: ->
        if not gDrive._authorized
            console.log("checkAuth")
            gapi.auth.authorize
                'client_id': "543454987250.apps.googleusercontent.com"
                'scope': "https://www.googleapis.com/auth/drive"
                'immediate': false
            , (authResult) ->
                if authResult and not authResult.error
                    gDrive._authorized = true
                    gDrive._currentFileListListeners.changed()
                    console.log("Google Auth", authResult)
                    if gDrive._callBack
                        gDrive._callBack()
                else
                    if authResult?.error?
                        console.log("Google Auth Error", authResult.error)
                    else
                        console.log("Google No Auth Return", authResult)
                    CoffeeAlerts.error("Google Authorization Failed  #{authResult?.error?.message}")
        else if gDrive._callBack?
            gDrive._callBack()

    
    call: (callBack) ->
        console.log("gDrive.call")
        gDrive._callBack = callBack
        if not gapi.client?.drive?
            console.log("gapi.client.drive is not loaded", gapi.client)
            gDrive.load()
        else
            gDrive.checkAuth()
    
    gotoDirectory: (file) ->
        gDrive.dirTree.push
            id: file.id
            title: file.title
        gDrive._currentFileListListeners.changed()

    uptoDirectory: ->
        gDrive.dirTree.pop()
        gDrive._currentFileListListeners.changed()

    currentDirectory: ->
        gDrive.dirTree[gDrive.dirTree.length-1]

    fileList: ->
        console.log("fileList")
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
        if gDrive._authorized and not gDrive._gettingList
            gDrive._gettingList = true
            console.log("getFileList")
            gDrive._callBack = null
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
                console.log("List Complete", gDrive._fileList.length)
                console.log("List Complete", gDrive._fileList)
                
                gDrive._gettingList = false
                gDrive.fileListLoaded = true

    getFileListInRootFolder: ->
        gDrive.getFilesInFolder('root')

    getFilesInFolder: (folderId) ->
        if gDrive._authorized and not gDrive._gettingList
            gDrive._gettingList = true
            console.log("getFileList")
            gDrive._callBack = null
            initialRequest = gapi.client.drive.children.list
                'folderId': folderId
            console.log("Initial request")
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
                console.log(gDrive._fileList)
                gDrive._gettingList = false
                gDrive.fileListLoaded = true




