
Template.googleDocs.created = ->
    console.log("googleDocs created")
    gDrive.reset()
    gDrive.init()

      
Template.googleDocs.rendered = ->
    console.log("googleDocs renderd")
    if gDrive.fileList().length is 0 or not gDrive.fileListLoaded
        gDrive.topDirectory = null
        gDrive.deleteOk = true;
        gDrive.testingOk = true;
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
        gDrive.userInitiatedAuth()
        gDrive.call(gDrive.getFileList)
        false

    "click #new-folder-test": (e) ->
        gDrive.createDirectory("Test Folder", "root")
        Meteor.defer ->
            window.scroll(0,0)
        false


Template.gDrive.helpers
    path: ->
        gDrive.path()

Template.gDriveFileList.helpers
    loading: ->
        gDrive.gettingFileList()

    haveFiles: ->
        gDrive.fileList?().length > 0

    files: ->
        gDrive.getFilesInCurrentFolder()

    haveFilesInCurrentDirectory: ->
        gDrive.getFilesInCurrentFolder().length > 0

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
        console.log("Read File", @downloadUrl)




