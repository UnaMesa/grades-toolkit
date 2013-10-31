
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

Template.googleDocs.events
    "click #authorize": (e) ->
        gDrive.call(gDrive.getFileList)


Template.fileList.helpers
    haveFiles: ->
        gDrive.fileList().length > 0

    files: ->
        gDrive.fileList()


Template.fileItem.helpers
    dateString: ->
        new moment(@createdDate).format("lll")


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

