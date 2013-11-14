
messagesIn = "in"
detailsIn = ""

Template.viewCase.created = ->
    messagesIn = "in"
    detailsIn = ""

Template.viewCase.rendered = ->
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

Template.viewCase.helpers
    case: ->
        theCase = Cases.findOne(Session.get('currentRecordId'))
        caseAsArray = []
        for key, value of theCase
            if key in ['submitted', 'modified']
                caseAsArray.push
                    key: key
                    value: moment(value).format('lll')
            else if key not in  ['_id','contact', 'userId', 'name', 'commentsCount', 'tag', 'urgent', 'BID']
                caseAsArray.push
                    key: key
                    value: value
            else if key is 'contact'
                caseAsArray.push
                    key: 'Contact'
                    value: value.name
                caseAsArray.push
                    key: 'Contact Number'
                    value: value.number
        caseAsArray

    caseId: ->
        Session.get('currentRecordId')

    messagesIn: ->
        messagesIn

    detailsIn: ->
        detailsIn

Template.viewCase.events
    "shown.bs.collapse #collapseMessages": (e)  ->
        console.log("shown.bs.collapse")
        setMessageListHeight()
        scrollToBottom()

    "click #new-note-link": (e) ->
        console.log('click')
        Session.set("showNewNoteDialog", true)



