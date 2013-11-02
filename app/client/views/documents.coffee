Template.docs.created = ->
    console.log("googleDocs created")
    gDrive.init()

Template.docs.rendered = ->
    console.log("googleDocs renderd")
    if gDrive.fileList().length is 0 or not gDrive.fileListLoaded
        gDrive.topDirectory = "FastFacts"
        gDrive.call(gDrive.getFileList)
    
Template.docs.destroyed = ->
    gDrive.fileListLoaded = false
  
Template.docs.helpers
    authorized: ->
        gDrive.authorized()

    authorizing: ->
        gDrive.authorizing()


Template.docs.events
    "click #authorize": (e) ->
        gDrive.userInitiatedAuth()
        gDrive.call(gDrive.getFileList)