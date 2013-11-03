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
            #console.log("Hide Spinner")
            $('#small-spinner').fadeTo(100, 0)
            if not scrollToBottomOK
                Meteor.defer ->
                    $('.messages-list-box').scrollTop($('#small-spinner').height() + 10)
      
setMessageListHeight = ->
    if $(".messages-list-box")?.offset?() and $("#new-message")?.offset?()
        maxHeight = $("#new-message").offset().top 
        maxHeight -= $(".messages-list-box").offset().top 
        maxHeight -= 5
        $(".messages-list-box").css("max-height", maxHeight + "px")
        messageWidth = $(".message").width() - $(".message-author-picture").width() - 20
        #console.log("messageWidth", $(".message").width(), $(".message-author-picture").width(), messageWidth)
        $(".message-body").css("max-width", messageWidth + "px")
        #console.log("setMessageListHeight:" + $(".messages-list-box").css("max-height"))

# If on a browser handle if the user resized the browser
$(window).resize(setMessageListHeight)

@newTag = ""


Template.messages.rendered = ->
    setMessageListHeight()
    scrollToBottom()
    hideSpinner()

Template.newMessageBox.rendered = ->
    newTag = ""

Template.newMessageBox.destroyed = ->
    newTag = ""

Template.newMessageBox.events
    "submit form": (e) =>
        e.preventDefault()
        console.log("Submit", @newTag, @newTag?)
        if @newTag?.length > 0 and not Meteor.call("tagIsValid", @newTag[1..])
            alert("Tag #{@newTag} is not valid")
            message = $("[name=message]").val()
            $("[name=message]").val(message[0..message.length-@newTag.length+1])
            @newTag = "#"
        else 
            @newTag = null
            message =
                message: $(e.target).find("[name=message]").val()

            Meteor.call "submitMessage", message, (error, id) ->
                if error
                    # Display error to the user
                    CoffeeAlerts.error(error.reason)
                else
                    console.log("New Message Insert")
                    scrollToBottomOK = true
                    scrollToBottom()
                    $(e.target).find("[name=message]").val("")
                

    "keydown": (e) =>
        console.log("keydown", e.keyCode)
        if e.keyCode is 8 # backspace
            if @newTag is '#'
                @newTag = ""
            else
                @newTag = @newTag[0..@newTag.length-2]
            console.log(@newTag)

    "keypress #new-message": (e) =>
        console.log("keypress", e.keyCode)
        if @newTag?.length > 0
            if e.keyCode is 32 # Got a space after a #string
                # check the tag
                console.log("Tag Done, do check", @newTag)
                if not Meteor.call("tagIsValid", @newTag[1..])
                    e.preventDefault()
                    alert("Tag #{@newTag} is not valid")
                    message = $("[name=message]").val()
                    fixedString = message[0..message.length-@newTag.length]
                    Meteor.defer ->
                        console.log("'#{fixedString}'")
                        $("[name=message]").val(fixedString)
                    @newTag = "#"
                else
                    @newTag = null
            else
                @newTag += String.fromCharCode(e.keyCode)
                console.log("tagging", @newTag)
        else if e.keyCode is 35  # We got a #
            @newTag = "#"
            console.log("starting tag", @newTag)
  
Template.messagesList.created = ->
    #console.log("created template messagesList")
    scrollToBottomOK = true

Template.messagesList.rendered = ->
    console.log("render template messagesList")
    # Note: messages.rendered should be called after this...
    #scrollToBottom()
    #hideSpinner()
    

Template.messagesList.destroyed = ->
    console.log("messasgeList destroyed")


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
        # use #each, Probably have to use the observe on the cursor
        #
        messages = cursor.fetch().reverse() # TODO: Find a better way 

    messagesReady: ->
        MessagesHandle.ready()
    
    allMessagesLoaded: ->
        MessagesHandle.ready() and Messages.find().count() < MessagesHandle.loaded()

Template.messagesList.events
    'scroll .messages-list-box': (e) ->
        if MessagesHandle.ready() and Messages.find().count() > MessagesHandle.loaded()
            #console.log("scroll:" + $('.messages-list-box').scrollTop())
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





