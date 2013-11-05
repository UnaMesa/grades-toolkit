#
#  Messages Page Back end  
#

###
TODO: Clean this up.  I went a little nuts trying to get things to work reliably.
I probably do not need all the Meteor.defer calls and the redundant calls to get
the scrolling correct.

###

scrollToTopOk = true
scrollToBottomOk = false

messageFilter = {}

@scrollToBottom = ->
    if scrollToBottomOk
        $('.messages-list-box').scrollTop($('.messages-list-box').prop("scrollHeight"))
        true

@scrollToTop = ->
    if scrollToTopOk
        $('.messages-list-box').scrollTop(0)
        true
  
@hideSpinner = ->
    Meteor.defer ->
        if MessagesHandle.ready()
            $('#small-spinner').fadeTo(100, 0)
            if not scrollToTopOk
                Meteor.defer ->
                    $('.messages-list-box').scrollTop($('.messages-list-box').prop("scrollHeight") - $('#small-spinner').height() - 10)
      
@setMessageListHeight = ->
    if $(".messages-list-box")?.offset? and $(".bottom-navbar")?.offset? and $("#new-message-group")?.height?
        if $(".navbar").hasClass("zero-height")
            maxHeight = $(window).height()
            maxHeight -= $("#new-message-group").height()
            maxHeight -= 1
        else
            maxHeight = $(".bottom-navbar").offset().top 
            maxHeight -= $(".messages-list-box").offset().top 
            maxHeight -= $("#new-message-group").height()
            maxHeight -= 1

        $(".messages-list-box").css("max-height", maxHeight + "px")
        messageWidth = $(".message").width() - $(".message-author-picture").width() - 20
        #console.log("messageWidth", $(".message").width(), $(".message-author-picture").width(), messageWidth)
        $(".message-body").css("max-width", messageWidth + "px")
        #console.log("message-list-box height:" + $(".messages-list-box").css("max-height"), fullscreen)
        maxHeight

# If on a browser handle if the user resized the browser
$(window).resize(setMessageListHeight)


Template.messages.rendered = ->
    setMessageListHeight()
    scrollToTop()
    hideSpinner()

Template.newMessageBox.created = ->
    console.log("newMessageBox created")

Template.newMessageBox.rendered = ->
    console.log("newMessageBox rendered")

Template.newMessageBox.destroyed = ->
    console.log("newMessageBox destroyed")
 
Template.newMessageBox.events
    "submit form": (e) ->
        e.preventDefault()
        message =
            message: $("[name=message]").val()
        if Session.get('messageTagFilter')? and Session.get('currentRecordId')?
            tag =
                type: Session.get('messageTagFilter')
                _id: Session.get('currentRecordId')
        else
            tag = null

        Meteor.call "submitMessage", message, tag, (error, id) ->
            if error
                # Display error to the user
                alert(error.reason)
            else
                scrollToTopOk = true
                scrollToTop()
                $(e.target).find("[name=message]").val("")


    "click #hash-input": (e) -> 
        console.log("hash-input click")
        e.preventDefault()
        $("[name=message]").val($("[name=message]").val()+ '#')
        $("[name=message]").focus()

    ###
    "focusin #new-message-group": (e) ->
        if not $(".navbar").hasClass("zero-height")
            $(".navbar").slideUp 200, ->
                $(".navbar").addClass("zero-height")
                $(document.body).addClass("zero-padding")
                setMessageListHeight()
    ###

    "keypress #new-message": (e) ->
        if e.keyCode is 32 # Got a space
            message = $("[name=message]").val()
            if tag = message.match(/\#[^ ]+$/)
                console.log("Tag", tag)
                Meteor.call "tagIsValid", tag[0], (error, result) ->
                    if error or not result
                        alert("Tag #{tag[0]} is not valid")
                        revertString = message[0..message.length - tag[0].length]
                        console.log("revert string", message.length, tag[0].length, tag, revertString)
                        $("[name=message]").val(revertString)


Template.messagesList.created = ->
    console.log("created template messagesList")
    scrollToTopOK = true
    messageFilter = {}
    if Session.get('messageTagFilter')?
            messageFilter = tags:
                $elemMatch:
                    type: 'case'
            if Session.get('currentRecordId')?
                messageFilter.tags.$elemMatch._id = Session.get('currentRecordId')

    console.log('filter', messageFilter)

Template.messagesList.rendered = ->
    console.log("render template messagesList")
    setMessageListHeight()
    

Template.messagesList.destroyed = ->
    console.log("messasgeList destroyed")


Template.messagesList.helpers
    haveMessages: ->
        console.log('haveMessages filter', @, messageFilter)
        Messages?.find?(messageFilter).count() > 0

    currentMessages: ->
        console.log('currentMessages filter', messageFilter)
        cursor = Messages.find messageFilter,
            sort:
                timestamp: -1
            limit: MessagesHandle.limit()
        #
        #   INVERT LIST
        #
        # I am afraid this rerenders all the cells on one cell change
        # BUT, cannot find a way to reverse the order on the cursor and
        # use #each, Probably have to use the observe on the cursor
        #
        #messages = cursor.fetch().reverse() # TODO: Find a better way 
        cursor

    messagesReady: ->
        MessagesHandle.ready()
    
    allMessagesLoaded: ->
        MessagesHandle.ready() and Messages.find(messageFilter).count() < MessagesHandle.loaded()

Template.messagesList.events
    'scroll .messages-list-box': (e) ->
        if MessagesHandle.ready() and Messages.find(messageFilter).count() > MessagesHandle.loaded()
            #console.log("scroll:" + $('.messages-list-box').scrollTop())
            if $('.messages-list-box').scrollTop() == $('.messages-list-box').prop("scrollHeight")
                $('#small-spinner').fadeTo(100, 1)
                Meteor.defer ->
                    $('.messages-list-box').scrollTop($('.messages-list-box').prop("scrollHeight") - 5)
                    console.log("Fetch Older messages")
                    scrollToTopOK = false
                    Meteor.defer ->
                        MessagesHandle.loadNextPage()

    "click .messages-list-box": (e) ->
        if $(".navbar").hasClass("zero-height")
            console.log("click", )
            $(".navbar").removeClass("zero-height")
            $(document.body).removeClass("zero-padding")
            $(".navbar").slideDown 200, ->
                setMessageListHeight()

Template.message.created = ->
    #console.log("message created")


Template.message.rendered = ->
    #console.log("message rendered", @data)

Template.message.helpers
    submittedText: ->
        new moment(@timestamp).format("llll")

    myMessage: ->
        @userId is Meteor.userId()

    displayMessage: ->
        if @tags?
            for tag in @tags
                @message = @message.replace(new RegExp(tag.tag,"g"), Template.tag(tag))
        @message

Template.author.helpers
    authorUrl: ->
        theAuther = Meteor.users.findOne(@userId)
        theAuther?.services?.google?.picture


Template.tag.helpers
    path: ->
        if @type is 'case'
            'viewCase'
        else 
            'contacts'



