
familyPhotoUploader = null

Template.familyPhotos.created = ->
    $('body').addClass("photoBody")
    if not familyPhotoUploader?
        familyPhotoUploader = new PhotoUploadHandler
            serverUploadMethod: "insertFamilyPhoto"
            takePhotoButtonLabel: "Add a Photo"
            uploadButtonLabel: "Save Photo"
            #resizeMaxHeight: 300
            #resizeMaxWidth: 320
            editTitle: true
            editCaption: true
            serverUploadOptions: 
                familyId: Session.get('currentRecordId')
            callback: (error, result) ->
                console.log("Photo Upload", error, result)


Template.familyPhotos.rendered = ->
    $('body').addClass("photoBody")

    familyPhotoUploader.setOptions
        serverUploadOptions: 
            familyId: Session.get('currentRecordId')

    $(".owl-carousel").owlCarousel
        #navigation : true # Show next and prev buttons
        slideSpeed : 300
        paginationSpeed : 400
        singleItem:true
        #itemsScaleUp:true
        autoHeight: true
        #autoPlay: 5000
        #rewindNav: false
        #rewindSpeed: 200
    

Template.familyPhotos.destroyed = ->
    $('body').removeClass("photoBody")


Template.familyPhotos.helpers

    haveImages: ->
        console.log('haveImages', FamilyPhotos)
        FamilyPhotos.find().count() > 0

    imageCount: ->
        FamilyPhotos.find().count()

    images: ->
        FamilyPhotos.find {},
            sort:
                submitted: -1

