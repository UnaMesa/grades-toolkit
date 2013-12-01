
familyPhotoUploader = null

FamilyPhotosHandle = null

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
    FamilyPhotosHandle = Meteor.subscribeWithPagination('familyPhotos', Session.get('currentRecordId'), 20)

Template.familyPhotos.destroyed = ->
    console.log("destroy")
    $('body').removeClass("photoBody")
    console.log(FamilyPhotosHandle)

Template.familyPhotos.rendered = ->
    $('body').addClass("photoBody")
    #FamilyPhotosHandle = Meteor.subscribeWithPagination('familyPhotos', Session.get('currentRecordId'), 20)


    familyPhotoUploader.setOptions
        serverUploadOptions: 
            familyId: Session.get('currentRecordId')

    if FamilyPhotosHandle?.ready()
        $(".owl-carousel").owlCarousel
            #navigation : true # Show next and prev buttons
            slideSpeed : 300
            paginationSpeed : 400
            singleItem:true
            #itemsScaleUp:true
            autoHeight: true
            transitionStyle : "fade"
            lazyLoad: true
            lazyFollow: true
            lazyLoadCallback: (img) ->
                if img
                    FamilyPhotos.findOne(img.data("src"))?.src
            afterLazyLoad: (base, elm) ->
                if elm
                    elm.find(".hide").removeClass("hide")

Template.familyPhotos.helpers

    imagesReady: ->
        FamilyPhotosHandle?.ready()

    haveImages: ->
        FamilyPhotos.find(
            family_id: Session.get('currentRecordId')
        ).count() > 0

    imageCount: ->
        FamilyPhotos.find(
            family_id: Session.get('currentRecordId')
        ).count()

    images: ->
        FamilyPhotos.find
            family_id: Session.get('currentRecordId')
        ,
            fields:
                src: 0
            sort:
                submitted: -1

