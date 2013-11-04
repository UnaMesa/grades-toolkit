
Template.viewCase.helpers
    case: ->
        theCase = Cases.findOne(Session.get('currentRecordId'))
        caseAsArray = []
        for key, value of theCase
            if key in ['submitted', 'modified']
                caseAsArray.push
                    key: key
                    value: moment(value).format('lll')
            else if key not in  ['_id','contact', 'userId', 'name', 'commentsCount', 'tag', 'urgent']
                caseAsArray.push
                    key: key
                    value: value
        caseAsArray

    caseId: ->
        Session.get('currentRecordId')

    isUrgent: ->
        console.log(@)
        @urgent is 'on'