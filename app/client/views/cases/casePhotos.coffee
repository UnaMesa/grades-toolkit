

casePhotoUploader = null
CasePhotosHandle  = null

Template.casePhotos.created = ->
    $('#main-container').addClass('main-container-inverse')
    $('body').addClass("photoBody")
    
    PhotoUploader.setOptions
        serverUploadMethod: "insertCasePhoto"
        takePhotoButtonLabel: "Add a Photo"
        uploadButtonLabel: "Save Photo"
        resizeMaxHeight: 400
        resizeMaxWidth: 320
        editTitle: true
        editCaption: true
        serverUploadOptions: 
            caseId: Session.get('currentRecordId')
        callback: (error, result) ->
            console.log("Photo Upload", error, result)
    CasePhotosHandle = Meteor.subscribeWithPagination('casePhotos', Session.get('currentRecordId'), 20)

Template.casePhotos.destroyed = ->
    console.log("destroy")
    $('body').removeClass("photoBody")
    $('#main-container').removeClass('main-container-inverse')
    console.log(CasePhotosHandle)

Template.casePhotos.rendered = ->
    $('#main-container').addClass('main-container-inverse')
    $('body').addClass("photoBody")
    #CasePhotosHandle = Meteor.subscribeWithPagination('casePhotos', Session.get('currentRecordId'), 20)


carouselInit = ->
    if CasePhotosHandle?.ready()
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
                    CasePhotos.findOne(img.data("src"))?.src
            afterLazyLoad: (base, elm) ->
                if elm
                    elm.find(".hide").removeClass("hide")

Template.casePhotos.helpers

    imagesReady: ->
        CasePhotosHandle?.ready()

    haveImages: ->
        CasePhotos.find(
            case_id: Session.get('currentRecordId')
        ).count() > 0

    imageCount: ->
        CasePhotos.find(
            case_id: Session.get('currentRecordId')
        ).count()

    images: ->
        if CasePhotosHandle?.ready()
            if $(".owl-carousel").data?('owlCarousel')?
                $(".owl-carousel").data('owlCarousel').destroy()
            Meteor.defer ->
                carouselInit()
                
            pc = CasePhotos.find
                    case_id: Session.get('currentRecordId')
                ,
                    fields:
                        src: 0
                    sort:
                        submitted: -1
            pc.fetch()

