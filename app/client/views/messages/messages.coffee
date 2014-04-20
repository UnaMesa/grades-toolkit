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


@messageFilter = ->
    filter = {}
    if Session.get('messageTagFilter')?
        filter = tags:
            $elemMatch:
                type: Session.get('messageTagFilter')
        if Session.get('currentRecordId')?
            filter.tags.$elemMatch._id = Session.get('currentRecordId')
    filter


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
            #scrollToTopOk = true
            #if not scrollToTopOk
            #    Meteor.defer ->
            #        $('.messages-list-box').scrollTop($('.messages-list-box').prop("scrollHeight") - $('#small-spinner').height() - 10)
      
@setMessageListHeight = ->
    if $(".bottom-navbar")?.offset? and $("#new-message-group")?.height?  # and $(".messages-list-box")?.offset?
        if $(".navbar").hasClass("zero-height")
            maxHeight = $(window).height()
            maxHeight -= 1
        else
            maxHeight = $(".bottom-navbar").offset().top 
            #maxHeight -= $(".messages-list-box").offset().top 
            maxHeight -= 1

        $(".messages-list-box").css("max-height", maxHeight + "px")
        maxHeight

@setMessageBodyWidth = ->
    messageWidth = $(".message").width() - $(".message-author-picture").width() - 20
    #console.log("messageWidth", $(".message").width(), $(".message-author-picture").width(), messageWidth)
    $(".message-body").css("max-width", messageWidth + "px")
    messageWidth

# If on a browser handle if the user resized the browser
$(window).resize(setMessageBodyWidth)

@scrollWatch = (e) ->
    #console.log("scrollWatch", $(window).scrollTop() + $(window).height(), $(document).height())
    if  $(window).scrollTop() + $(window).height() >= $(document).height()
        #console.log("check for more messages", Messages.find(messageFilter()).count(), MessagesHandle.loaded())
        if MessagesHandle.ready() and Messages.find(messageFilter()).count() >= MessagesHandle.loaded()
            $('#small-spinner').fadeTo(100, 1)
            Meteor.defer ->
                console.log("Fetch Older messages")
                scrollToTopOK = false
                Meteor.defer ->
                    MessagesHandle.loadNextPage()

Template.messages.created = ->
    $(window).on("scroll", scrollWatch)

Template.messages.destroyed = ->
    $(window).off("scroll", scrollWatch)

Template.messages.rendered = ->
    #setMessageListHeight()
    setMessageBodyWidth()
    scrollToTop()
    hideSpinner()


Template.messagesList.created = ->
    #console.log("created template messagesList")
    scrollToTopOK = true


Template.messagesList.rendered = ->
    #console.log("render template messagesList")
    #setMessageListHeight()
    setMessageBodyWidth()
    

Template.messagesList.destroyed = ->
#    console.log("messasgeList destroyed")


Template.messagesList.helpers
    haveMessages: ->
        filter = messageFilter()
        Messages?.find?(filter).count() > 0

    currentMessages: ->
        filter = messageFilter()
        @messages = Messages.find filter,
            sort:
                timestamp: -1
            limit: MessagesHandle.limit()

        @messages.map (message, index, cursor) ->
            message._rank = index
            message

    messagesReady: ->
        MessagesHandle.ready()
    
    allMessagesLoaded: ->
        count = Messages.find(messageFilter()).count()
        console.log("allMessagesLoaded",  "ready", MessagesHandle.ready(), "count",  count, "loaded", MessagesHandle.loaded())
        MessagesHandle.ready() and count < MessagesHandle.loaded()


Template.message.created = ->
    #console.log("message created")


Template.message.rendered = ->
    instance = @
    rank = instance.data._rank
    $this = $(@firstNode)
    messageHeight = 67
    newPosition = rank * messageHeight
    # If element has a currentPosition (i.e. it is not the first ever render)
    if typeof(instance.currentPosition) isnt 'undefined'
        previousPosition = instance.currentPosition
        # Calculate difference between old position and new position and send element there
        delta = previousPosition - newPosition
        $this.css("top", delta + "px");
    else
        $this.addClass("invisible")
        #$this.css('opacity', 0)
    
    # Let it draw in the old position, then..
    Meteor.defer ->
        instance.currentPosition = newPosition
        # Bring element back to its new original position
        $this.css("top",  "0px").removeClass("invisible")
        #$this.removeClass("invisible")
        #$this.css('opacity', 1)

tagToUrl = (tag) ->
    switch tag?.type
        when 'case'
            Router.routes['viewCase'].path(tag)
        when 'family'
            Router.routes['viewFamily'].path(tag)
        else
            Router.routes['contacts'].path() # TODO: Change this

Template.message.helpers
    submittedText: ->
        now = moment()
        postDate = moment(@timestamp)
        diff = now.diff(postDate, 'hours')
        if diff > 36
            new moment(@timestamp).format("D MMM")
        else
            moment.duration(now.diff(postDate)).humanize()

    myMessage: ->
        @userId is Meteor.userId()

    displayMessage: ->
        if @tags?.length?
            for tag in @tags
                if tag?
                    url = tagToUrl(tag)
                    #link = "<a href='#{url}'><span class='label label-default tag-#{tag.type}'>#{tag.name} <i>#{tag.tag}</i></span></a>"
                    link = "<a href='#{url}'>#{tag.name}<small><i>(#{tag.tag})</i></small></a>"
                    @message = @message.replace(new RegExp(tag.tag,"g"), link) 
                    # Template.tag(tag)) # Using a reactive template blew chow
        @message

    displayTags: ->
        if @tags?.length?
            for tag in @tags
                if tag?
                    tag.url = tagToUrl(tag)
            @tags


Template.author.helpers
    authorUrl: ->
        theAuthor = Meteor.users.findOne(@userId)
        theAuthor?.services?.google?.picture

    authorTag: ->
        theAuthor = Meteor.users.findOne(@userId)
        theAuthor?.tag

Template.tag.helpers
    path: ->
        switch @type
            when 'case'
                'viewCase'
            when 'family'
                'viewFamily'
            when 'case'
                'contacts' #viewContacts'
            else
                'contacts'


