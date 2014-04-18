
Template.googleDocs.created = ->
    console.log("googleDocs created")
    gDrive.fullReset()
    gDrive.init()

      
Template.googleDocs.rendered = ->
    console.log("googleDocs renderd")
    if gDrive.fileList().length is 0 or not gDrive.fileListLoaded
        gDrive.topDirectory = null
        gDrive.deleteOk = true
        gDrive.testingOk = true
        gDrive.call(gDrive.getFileList)
    
Template.googleDocs.destroyed = ->
    gDrive.fileListLoaded = false
  
Template.googleDocs.helpers
    authorized: ->
        gDrive.authorized()

    authorizing: ->
        gDrive.authorizing()


Template.googleDocs.events
    "click #authorize": (e) ->
        e.preventDefault()
        gDrive.userInitiatedAuth()
        gDrive.call(gDrive.getFileList)
        false

    "click #new-folder": (e) ->
        e.preventDefault()
        CoffeeAlerts.clearSeen()
        $(".has-error").removeClass('has-error')
        folderName = $('#new-folder-name').val()
        if not folderName
            CoffeeAlerts.error("No new folder name!")
            $('#new-folder-name').parent().addClass('has-error')
        else
            console.log("new folder", folderName)
            gDrive.createDirectory(folderName, "root")
            Meteor.defer ->
                $('#new-folder-name').val("")
                window.scroll(0,0)
            false

    "click #test": (e) ->
        e.preventDefault()
        console.log('Run Google Test', gapi.auth.getToken())

        # Find File we want

        Meteor.call "googleDocTest", fileId, (error, result) ->
            if error
                CoffeeAlerts.error("Google Test Error #{error.message}")


Template.gDrive.helpers
    path: ->
        gDrive.path()

Template.gDriveFileList.helpers
    loading: ->
        gDrive.gettingFileList()

    haveFiles: ->
        #console.log('haveFiles', gDrive.fileList?(), gDrive.fileList?()[0]?)
        #console.log(gDrive.fileList?().length > 0 and gDrive.fileList?()[0]?)
        gDrive.fileList?().length > 0 and gDrive.fileList?()[0]?

    files: ->
        gDrive?.getFilesInCurrentFolder?()

    haveFilesInCurrentDirectory: ->
        gDrive?.getFilesInCurrentFolder?().length > 0

Template.gDriveFileList.events
    "click #authorize": (e) ->
        e.preventDefault()
        gDrive.userInitiatedAuth()
        gDrive.call(gDrive.getFileList)
        false

Template.gDrive.events
    "click .path-link": (e) ->
        gDrive.uptoDirectory($(e.target).attr('id'))


Template.gDriveItem.helpers
    dateString: ->
        new moment(@createdDate).format("lll")

    isaFolder: ->
        @mimeType is 'application/vnd.google-apps.folder'

    deleteOk: ->
        gDrive.deleteOk and @editable

    testingOk: ->
        gDrive.testingOk

    getDownLoadUrl: ->
        if @downloadUrl
            @downloadUrl
        else if @exportLinks?["application/pdf"]
            @exportLinks?["application/pdf"]
        else if @exportLinks?["text/html"]
            @exportLinks?["text/html"]

Template.gDriveItem.events
    "click .delete-file": (e) ->
        if confirm("Are you sure you want to delete '#{@title}'")
            console.log("Deleting", @title)
            theId = @id
            # change trash to delete to really delete it
            gapi.client.drive.files.trash(
                'fileId': @id
            ).execute (response) ->
                console.log(response, theId)
                CoffeeAlerts.info("Deleted document")
                gDrive.removeFileFromList(theId) 
                Meteor.defer ->
                    gDrive.getFileList()

    "click .folder": (e) ->
        console.log("Get Directory", @title, @)
        gDrive.gotoDirectory(@)


    "click .read-file": (e) ->
        console.log("Read File", @)
        Meteor.call "googleFetchDoc", @, (result) ->
            console.log(result)
        , (error, result) ->
            if error
                CoffeeAlerts.error("Google Test Error #{error.message}")
            else
                console.log("Read OK", result)
           




