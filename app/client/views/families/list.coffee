

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

    "click .family": (e) ->
        Router.go 'viewFamily',
            _id: @_id 


Template.family.helpers
    name: ->
        @["firstname"] + " " + @["lastname"]

    type: ->
        'family'
