

Template.families.helpers

    haveFamilies: ->
        Families.find().count() > 0

    sortedFamilies: ->
        Families.find {},
            sort: 
                'name': 1
            limit: FamiliesHandle.limit()
    
    familiesReady: ->
        FamiliesHandle.ready()
    
    allFamiliesLoaded: ->
        FamiliesHandle.ready() and Families.find().count() < FamiliesHandle.loaded()


Template.families.events
    'click .load-more': (e) ->
        e.preventDefault()
        FamiliesHandle.loadNextPage()

    "click .record": (e) ->
        #e.preventDefault()
        Router.go 'viewFamily',
            _id: @_id 


Template.familySummary.helpers
    name: ->
        @["firstname"] + " " + @["lastname"]

    type: ->
        'family'
