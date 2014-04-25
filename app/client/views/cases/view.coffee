
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
            height =  setMessageListHeight()
            $("#collapseMessages").css("height", height + "px")
            scrollToBottom()
    $("#collapseDetails").on "hidden.bs.collapse", ->
        detailsIn = ""
        Meteor.defer ->
            height = setMessageListHeight()
            $("#collapseMessages").css("height", height + "px")

Template.viewCase.helpers
    case: ->
        caseAsArray = []
        for key, value of @
            if key in ['submitted', 'modified']
                caseAsArray.push
                    key: key
                    value: moment(value).format('lll')
            else if key is 'dcfId'
                caseAsArray.push
                    key: "DCF Family/Child#"
                    value: value
            else if key is 'contact'
                caseAsArray.push
                    key: 'Contact'
                    value: value.name
                caseAsArray.push
                    key: 'Contact Number'
                    value: value.number
            else if key not in  ['_id','contact', 'userId', 'name', 'commentsCount', 'tag', 'urgent', 'BID', 'MOU', 'picture', 'goBackPath']
                caseAsArray.push
                    key: key
                    value: value
        caseAsArray

    caseId: ->
        Session.get('currentRecordId')

    messagesIn: ->
        messagesIn

    detailsIn: ->
        detailsIn

    stayAtCurrentSchool: ->
        @BID?.teamRecommendation is 'stayAtCurrentSchool'

Template.viewCase.events
    "shown.bs.collapse #collapseMessages": (e)  ->
        setMessageListHeight()
        scrollToBottom()

    "click #new-note-link": (e) ->
        console.log('click')
        Session.set("showNewNoteDialog", true)



