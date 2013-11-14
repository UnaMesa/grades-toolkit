
messagesIn = "in"
detailsIn = ""

Template.viewContact.created = ->
    messagesIn = "in"
    detailsIn = ""

Template.viewContact.rendered = ->
    $("#collapseMessages").on "hidden.bs.collapse", ->
        messagesIn = ""
    $("#collapseDetails").on "shown.bs.collapse", ->
        detailsIn = "in"
    $("#collapseMessages").on "shown.bs.collapse", ->
        messagesIn = "in"
        Meteor.defer ->
            console.log("shown.bs.collapse")
            height =  setMessageListHeight()
            $("#collapseMessages").css("height", height + "px")
            scrollToBottom()
    $("#collapseDetails").on "hidden.bs.collapse", ->
        detailsIn = ""
        Meteor.defer ->
            console.log("shown.bs.collapse")
            height = setMessageListHeight()
            $("#collapseMessages").css("height", height + "px")

Template.viewContact.helpers
    fields: ->
        theRecord = Meteor.users.findOne(Session.get('currentRecordId'))
        console.log('userRecord', theRecord)
        recordAsArray = [
            key: "Email" 
            value: theRecord.services.google.email
        ]
        for key, value of theRecord
            if key in ['submitted', 'modified']
                recordAsArray.push
                    key: key
                    value: moment(value).format('lll')
            else if key is 'lastLoginAt'
                recordAsArray.push
                    key: 'Last Login'
                    value: moment(value).format('lll')
        recordAsArray

    recordId: ->
        Session.get('currentRecordId')

    isUrgent: ->
        @urgent is 'on'

    messagesIn: ->
        messagesIn

    detailsIn: ->
        detailsIn

Template.viewContact.events
    "shown.bs.collapse #collapseMessages": (e)  ->
        console.log("shown.bs.collapse")
        setMessageListHeight()
        scrollToBottom()

    "click #new-note-link": (e) ->
        console.log('click')
        Session.set("showNewNoteDialog", true)


Template.contactSummary.helpers
    me: ->
        Meteor.userId() is @_id

    type: ->
        'user'

