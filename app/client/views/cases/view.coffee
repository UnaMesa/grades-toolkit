
Template.viewCase.helpers
    case: ->
        theCase = Cases.findOne(Session.get('currentCaseId'))
        caseAsArray = []
        for key, value of theCase
            if key in ['submitted', 'modified']
                caseAsArray.push
                    key: key
                    value: moment(value).format('llll')
            else if key not in  ['_id','contact', 'userId', 'name', 'commentsCount']
                caseAsArray.push
                    key: key
                    value: value
        console.log(caseAsArray)
        caseAsArray
