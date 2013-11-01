
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

    directory: ->
        if gDrive.currentDirectory().id isnt 'root'
            gDrive.currentDirectory().title

Template.googleDocs.events
    "click #authorize": (e) ->
        gDrive.call(gDrive.getFileList)

    "click #parent-dir": (e) ->
        gDrive.uptoDirectory()


Template.fileList.helpers
    haveFiles: ->
        gDrive.fileList().length > 0

    files: ->
        theFiles = []
        console.log("Get files in ", gDrive.currentDirectory().title)
        for file in gDrive.fileList()
            if gDrive.currentDirectory().id is 'root'
                if file.parents?[0]?.isRoot
                    theFiles.push file
                    console.log("root file/dir", file)
            else if file.parents?[0]?.id is gDrive.currentDirectory().id
                theFiles.push file
                console.log("file/dir in", file.title, gDrive.currentDirectory().id, file.parents)
        theFiles


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




