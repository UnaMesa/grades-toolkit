###
Template.docs.created = ->
    console.log("documents created")
    gDrive.reset()
    gDrive.init()

Template.docs.rendered = ->
    console.log("documents renderd")
    if gDrive.fileList().length is 0 or not gDrive.fileListLoaded
        gDrive.deleteOk = false
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

###

Template.docs.rendered = ->
    console.log("docs rendered", @)

Template.docs.helpers
    link: ->
        @embedLink or @webContentLink
