
Template.generatedBid.rendered = ->
    console.log("generatedBid Rendered")
    $('body').addClass('bidForm')


Template.generatedBid.helpers
    
    documentsUsedForBid: ->
        vals = []
        for val in BID.documentsUsed
             data =
                 key: val
             if @BID?.documentsUsed and val in @BID.documentsUsed
                 data.checked = "check-"
             vals.push(data)
        vals

    considerations: ->
        considerations = []
        index = 0
        for consideration in BID.considerations
            data = _.clone(consideration)
            index++
            data.index = index
            if data.helpBlock
                data.helpText = "<ul>"
                for help in data.helpBlock
                    data.helpText +=  '<li>' + help + '</li>';
                data.helpText += "</ul>"
            if @BID?.considerations
                for theCons in @BID.considerations
                    if theCons.key is data.key
                        data.factors = theCons.factors
                        switch theCons.yesNo
                            when 'yes'
                                data.yes = "check-"
                            when 'no'
                                data.no = "check-"
                        break
            considerations.push(data)
        
        considerations

    stayAtCurrentSchool: ->
        console.log("stayAtCurrentSchool", @BID)
        @BID?.teamRecommendation is 'stayAtCurrentSchool'
        
    moveToNewSchool: ->
        @BID?.teamRecommendation is 'moveToNewSchool'

    teamDisagrees: ->
        @BID?.teamRecommendation is 'teamDisagrees'


    currentSchool: ->
        if @BID?.teamRecommendation is 'stayAtCurrentSchool'
            @BID.schoolToAttend
        else
            " &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; "

    currentSUSD: ->
        if @BID?.teamRecommendation is 'stayAtCurrentSchool'
            @BID.susd
        else
            " &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; "

    newSchool: ->
        if @BID?.teamRecommendation is 'moveToNewSchool'
            @BID.schoolToAttend
        else
            " &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; "

    newSUSD: ->
        if @BID?.teamRecommendation is 'moveToNewSchool'
            @BID.susd
        else
            " &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; "




