
Template.cases.rendered = ->
    console.log("Cases Rendered")
    #$("[rel='tooltip']").tooltip()


Template.cases.helpers
    haveCases: ->
        Cases.find().count() > 0

    sortedCases: ->
        Cases.find {},
            sort: 
                modified: -1
            limit: CasesHandle.limit()

    
    casesReady: ->
        CasesHandle.ready()
    
    allCasesLoaded: ->
        CasesHandle.ready() and Cases.find().count() < CasesHandle.loaded()

Template.cases.events
    "click .load-more": (e) ->
        CasesHandle.loadNextPage()


Template.case.events
    "click .case": (e) ->
        console.log("case click", @_id)
        Router.go 'viewCase',
            _id: @_id 