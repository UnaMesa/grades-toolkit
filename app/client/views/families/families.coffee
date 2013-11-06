

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


Template.contact.helpers
    me: ->
        Meteor.userId() is @_id

    type: ->
        'user'