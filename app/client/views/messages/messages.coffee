#
#  Messages Page Back end  
#

###
TODO: Clean this up.  I went a little nuts trying to get things to work reliably.
I probably do not need all the Meteor.defer calls and the redundant calls to get
the scrolling correct.

###

scrollToBottomOK = true

@scrollToBottom = ->
    if scrollToBottomOK
        #console.log("scrollToBottom")
        $('.messages-list-box').scrollTop($('.messages-list-box').prop("scrollHeight"))
        true

@scrollToTop = ->
    $('.messages-list-box').scrollTop(1)
  
@hideSpinner = ->
    Meteor.defer ->
        if MessagesHandle.ready()
            console.log("Hide Spinner")
            $('#small-spinner').fadeTo(100, 0)
            if not scrollToBottomOK
                Meteor.defer ->
                    $('.messages-list-box').scrollTop($('#small-spinner').height() + 10)
      
setMessageListHeight = ->
    if $(".messages-list-box")?.offset?() and $("#new-message")?.offset?()
        maxHeight = $("#new-message").offset().top 
        maxHeight -= $(".messages-list-box").offset().top 
        maxHeight -= 10
        $(".messages-list-box").css("max-height", maxHeight + "px")
        messageWidth = $(".message").width() - $(".contact-picture").width() - 30
        console.log("messageWidth", messageWidth)
        $(".message-body").css("max-width", messageWidth + "px")
        #console.log("setMessageListHeight:" + $(".messages-list-box").css("max-height"))

# If on a browser handle if the user resized the browser
$(window).resize(setMessageListHeight)

Template.messages.events
    "submit form": (e) ->
        e.preventDefault()
        
        message =
            message: $(e.target).find("[name=message]").val()

        Meteor.call "submitMessage", message, (error, id) ->
            if error
                # Display error to the user
                CoffeeErrors.throw(error.reason)
            else
                console.log("New Message Insert")
                scrollToBottomOK = true
                scrollToBottom()
                $(e.target).find("[name=message]").val("")
                

    
Template.messages.rendered = ->
    console.log("render template messages")
    #_.once ->
    setMessageListHeight()
    scrollToBottom()
    hideSpinner()
    
Template.messagesList.created = ->
    console.log("created template messagesList")
    scrollToBottomOK = true

Template.messagesList.rendered = ->
    console.log("render template messagesList")
    # Note: messages.rendered should be called after this...
    #scrollToBottom()
    #hideSpinner()
        
Template.messagesList.helpers
    haveMessages: ->
        Messages?.find?().count() > 0

    currentMessages: ->
        cursor = Messages.find {},
            sort:
                timestamp: -1
            limit: MessagesHandle.limit()
        #
        # I am affraid this rerenders all the cells on one cell change
        # BUT, cannot find a way to reverse the order on the cursor and
        # use #each
        #
        messages = cursor.fetch().reverse() # TODO: Find a better way 

    messagesReady: ->
        MessagesHandle.ready()
    
    allMessagesLoaded: ->
        MessagesHandle.ready() and Messages.find().count() < MessagesHandle.loaded()

Template.messagesList.events
    'scroll .messages-list-box': (e) ->
        if MessagesHandle.ready() and Messages.find().count() > MessagesHandle.loaded()
            console.log("scroll:" + $('.messages-list-box').scrollTop())
            if $('.messages-list-box').scrollTop() == 0
                $('#small-spinner').fadeTo(100, 1)
                Meteor.defer ->
                    $('.messages-list-box').scrollTop(5)
                    console.log("Fetch Older messages")
                    scrollToBottomOK = false
                    Meteor.defer ->
                        MessagesHandle.loadNextPage()

Template.message.rendered = ->
    #console.log("message rendered")

    ###
    # Commenting out for they should get called above 
    # when the outer template is rendered
    ###
    #scrollToBottom()
    #hideSpinner()

Template.message.helpers
    submittedText: ->
        new moment(@timestamp).format("llll")

    myMessage: ->
        @userId is Meteor.userId()


Template.author.helpers
    authorUrl: ->
        theAuther = Meteor.users.findOne(@userId)
        theAuther?.services?.google?.picture





