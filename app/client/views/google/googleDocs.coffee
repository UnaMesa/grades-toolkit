
Template.googleDocs.created = ->
    console.log("googleDocs created")
    gDrive.init(gDrive.getFileList)
      
Template.googleDocs.rendered = ->
    console.log("googleDocs renderd")
    if gDrive.fileList().length is 0 or gDrive.dirty
        gDrive.getFileList()
    
  
Template.fileList.helpers
    haveFiles: ->
        gDrive.fileList().length > 0

    files: ->
        gDrive.fileList()


Template.fileItem.helpers
    dateString: ->
        new moment(@createdDate).format("llll")

