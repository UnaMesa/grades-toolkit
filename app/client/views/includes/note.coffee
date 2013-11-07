

Template.newNote.created = ->
    console.log("newNote created")
    Session.set("showNewNoteDialog", false)
    #if not _tagLiseners
    #    _tagLiseners = new Deps.Dependency()
    
Template.newNote.rendered = ->
    console.log("newNote rendered")
    
Template.newNote.events
    "click #new-note-link": (e) ->
        console.log('click')
        Session.set("showNewNoteDialog", true)
        
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
    console.log("newNoteDialog rendered")
    Meteor.defer ->
        $("[name=message]").focus()
        #$("#tag-input").click()


Template.newNoteDialog.helpers
    title: ->
        "New Note"

    haveTags: ->
        console.log("haveTags")
        Session.get("tags")?.keys?().length > 0

    tags: ->
        console.log("tags")
        objectToArray(Session.get("tags"))
        

Template.newNoteDialog.events
    "click #dismiss": (e) ->
        console.log("dismiss")
        #$("#newNoteModal").animate
        #    opacity: 0.1
        #, 200, ->
        #    $("#newNoteModal").addClass("fade")
        Session.set("showNewNoteDialog", false)

    "click .mask": (e) ->
        console.log("mask click")
        Session.set("showNewNoteDialog", false)

    "click #cancel": (e) ->
        Session.set("showNewNoteDialog", false)

    "click #tag-input": (e) -> 
        console.log("hash-input click")
        e.preventDefault()
        $("[name=message]").val($("[name=message]").val()+ '#')
        $("[name=message]").focus()

    "click #at-input": (e) -> 
        console.log("hash-input click")
        e.preventDefault()
        $("[name=message]").val($("[name=message]").val()+ '@')
        $("[name=message]").focus()

    "submit form": (e) ->
        e.preventDefault()
        console.log("submit form")
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
                console.log('hide')
        
    "focus #messageTextArea": (e) ->
        console.log("focus", e)
        el = e.target
        el.selectionStart = el.selectionEnd = el.value.length

    "keypress #messageTextArea": (e) ->
        if e.keyCode is 32 # Got a space
            message = $("[name=message]").val()
            if tag = message.match(/\#[^ ]+$/) or message.match(/\@[^ ]+$/)
                console.log("Tag", tag, tag[0])
                Meteor.call "tagIsValid", tag[0], (error, result) ->
                    if error or not result
                        if not confirm("Tag #{tag[0]} is not valid")
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
                                console.log("addPageTag", tags)




