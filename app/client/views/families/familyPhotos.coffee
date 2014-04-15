
familyPhotoUploader = null

FamilyPhotosHandle = null

Template.familyPhotos.created = ->
    $('#main-container').addClass('main-container-inverse')
    $('body').addClass("photoBody")
    PhotoUploader.setOptions
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
    $('#main-container').removeClass('main-container-inverse')
    console.log(FamilyPhotosHandle)


carouselInit = ->
    if FamilyPhotosHandle?.ready()
        $(".owl-carousel").owlCarousel
            #navigation : true # Show next and prev buttons
            slideSpeed : 300
            paginationSpeed : 400
            singleItem:true
            transitionStyle : "fade"
            #itemsScaleUp:true
            autoHeight: true
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
        if FamilyPhotosHandle?.ready()
            if $(".owl-carousel").data?('owlCarousel')?
                $(".owl-carousel").data('owlCarousel').destroy()
            Meteor.defer ->
                carouselInit()
            
            pc = FamilyPhotos.find
                    family_id: Session.get('currentRecordId')
                ,
                    fields:
                        src: 0
                    sort:
                        submitted: -1
            console.log("images?", pc.count())
            pc.fetch()
