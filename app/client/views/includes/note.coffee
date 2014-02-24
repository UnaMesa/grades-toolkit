

Template.newNote.created = ->
    #console.log("newNote created")
    Session.set("showNewNoteDialog", false)
    #if not _tagLiseners
    #    _tagLiseners = new Deps.Dependency()
    
Template.newNote.rendered = ->
    #console.log("newNote rendered")
    
Template.newNote.events
    "click #new-note-link": (e) ->
        window.scrollTo(0, 0)
        e.stopPropagation();
        e.preventDefault();
        Session.set("showNewNoteDialog", true)
        Meteor.defer ->
            window.scrollTo(0, 0)
        #$("#newNoteModal").animate
        #    opacity: 1
        #, 200, ->
        #    $("#newNoteModal").removeClass("fade")

Template.newNote.helpers
    showNewNoteDialog: ->
        Session.get("showNewNoteDialog")

#
#  New Note Dialog
#

Template.newNoteDialog.rendered = ->
    #console.log("newNoteDialog rendered")
    Meteor.defer ->
        $("[name=message]").focus()
        #$("#tag-input").click()


Template.newNoteDialog.helpers
    title: ->
        "New Note"

    haveTags: ->
        #console.log("haveTags")
        Session.get("tags")?.keys?().length > 0

    tags: ->
        objectToArray(Session.get("tags"))
        
    numberOfRows: ->
        if Session.get("landscape")
            2
        else
            3

Template.newNoteDialog.events
    "click #dismiss": (e) ->
        e.stopPropagation()
        e.preventDefault()
        #$("#newNoteModal").animate
        #    opacity: 0.1
        #, 200, ->
        #    $("#newNoteModal").addClass("fade")
        Session.set("showNewNoteDialog", false)

    "click .mask": (e) ->
        e.stopPropagation()
        e.preventDefault()
        Session.set("showNewNoteDialog", false)

    "click #cancel": (e) ->
        e.stopPropagation()
        e.preventDefault()
        Session.set("showNewNoteDialog", false)

    "click #tag-input": (e) -> 
        e.stopPropagation()
        e.preventDefault()
        $("[name=message]").val($("[name=message]").val()+ '#')
        $("[name=message]").focus()


    "click #at-input": (e) -> 
        e.stopPropagation()
        e.preventDefault()
        $("[name=message]").val($("[name=message]").val()+ '@')
        $("[name=message]").focus()
    

    "submit form": (e) ->
        e.preventDefault()
        message =
            message: $("[name=message]").val()

        tags = objectToArray(Session.get("tags"))
        
        Meteor.call "submitMessage", message, tags, (error, id) ->
            if error
                # Display error to the user
                alert(error.reason)
            else
                $(e.target).find("[name=message]").val("")
                Session.set("showNewNoteDialog", false)
        
    "focus #messageTextArea": (e) ->
        el = e.target
        el.selectionStart = el.selectionEnd = el.value.length

    "keypress #messageTextArea": (e) ->
        if e.keyCode is 32 # Got a space
            message = $("[name=message]").val()
            if tag = message.match(/\#[^ ]+$/) or message.match(/\@[^ ]+$/)
                Meteor.call "tagIsValid", tag[0], (error, result) ->
                    if error or not result
                        if confirm("Tag #{tag[0]} is not valid.  Remove it?")
                            revertString = message[0..message.length - tag[0].length]
                            console.log("revert string", message.length, tag[0].length, tag, revertString)
                            $("[name=message]").val(revertString)
                    else if result
                        tag =
                            tag: result.tag
                            _id: result._id
                        Meteor.call "getFullTag", tag, (error, tag) ->
                            if not error? and tag?
                                tags = Session.get("tags")
                                tags[tag.tag] = tag
                                Session.set("tags", tags)
                                #$("[name=message]").val($("[name=message]").val().)
                            else
                                console.log("getFullTag Error", error, tag)




