
Template.googleDocs.created = ->
    console.log("googleDocs created")
    gDrive.init()
      
Template.googleDocs.rendered = ->
    console.log("googleDocs renderd")
    if gDrive.fileList().length is 0 or not gDrive.fileListLoaded
        gDrive.call(gDrive.getFileList)
    
Template.googleDocs.destroyed = ->
    gDrive.fileListLoaded = false
  
Template.googleDocs.helpers
    authorized: ->
        gDrive.authorized()

    authorizing: ->
        gDrive.authorizing()

    directory: ->
        if gDrive.currentDirectory().id isnt 'root'
            gDrive.currentDirectory().title

    path: ->
        gDrive.path()

Template.googleDocs.events
    "click #authorize": (e) ->
        console.log("authorized clicked")
        gDrive.userInitiatedAuth()
        gDrive.call(gDrive.getFileList)

    "click #parent-dir": (e) ->
        gDrive.uptoDirectory()

    "click .path-link": (e) ->
        console.log($(e.target).attr('id'))
        gDrive.uptoDirectory($(e.target).attr('id'))


Template.fileList.helpers
    loading: ->
        console.log("loading called", gDrive.gettingFileList())
        gDrive.gettingFileList()

    haveFiles: ->
        gDrive.fileList().length > 0

    files: ->
        gDrive.getFilesInCurrentFolder()


Template.fileItem.helpers
    dateString: ->
        new moment(@createdDate).format("lll")

    isaFolder: ->
        @mimeType is 'application/vnd.google-apps.folder'

Template.fileItem.events
    "click .delete-file": (e) ->
        if confirm("Are you sure you want to delete '#{@title}'")
            console.log("Deleting", @title)
            theId = @id
            gapi.client.drive.files.delete(
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




