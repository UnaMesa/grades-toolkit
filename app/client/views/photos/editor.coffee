

photoUploader = null

Template.photoEditor.created = ->
    if not photoUploader?
        photoUploader = new PhotoUploadHandler
            serverUploadMethod: "submitPhoto"
            takePhotoButtonLabel: "Take Photo"
            uploadButtonLabel: "Save Photo"
            resizeMaxHeight: 300
            resizeMaxWidth: 300
            serverUploadOptions: 
                recordId: Session.get('currentRecordId')
                recordType: Session.get('messageTagFilter')
            callback: (error, result) ->
                console.log("Photo Upload", error, result)


Template.photoEditor.rendered = ->
    photoUploader.setOptions
        serverUploadOptions: 
            recordId: Session.get('currentRecordId')
            recordType: Session.get('messageTagFilter')

Template.photoEditor.helpers
    isCase: ->
        Session.get('messageTagFilter') is 'case'

    isFamily: ->
        Session.get('messageTagFilter') is 'family'

    isUser: ->
        Session.get('messageTagFilter') is 'user'