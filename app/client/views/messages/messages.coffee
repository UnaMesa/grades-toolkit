
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
        console.log("setMessageListHeight:" + $(".messages-list-box").css("max-height"))

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
    setMessageListHeight()
    scrollToBottom()
    hideSpinner()
    
Template.messagesList.created = ->
    console.log("created template messagesList")
    scrollToBottomOK = true

Template.messagesList.rendered = ->
    console.log("render template messagesList")
    scrollToBottom()
    hideSpinner()
        
Template.messagesList.helpers
    haveMessages: ->
        Messages?.find?().count() > 0

    currentMessages: ->
        cursor = Messages.find {},
            sort:
                timestamp: -1
            limit: MessagesHandle.limit()
        messages = cursor.fetch().reverse()

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

        #else
        #    scrollToBottomOK = true

Template.message.rendered = ->
    #console.log("message rendered")
    scrollToBottom()
    hideSpinner()

Template.message.helpers
    submittedText: ->
        new moment(@timestamp).format("llll")

    myMessage: ->
        @userId is Meteor.userId()


Template.author.helpers
    authorUrl: ->
        theAuther = Meteor.users.findOne(@userId)
        theAuther?.services?.google?.picture




