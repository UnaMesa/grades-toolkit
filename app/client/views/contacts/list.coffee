

Template.contacts.helpers     
    sortedContacts: ->
        Meteor.users.find {},
            sort: 
                'services.google.family_name': 1
                'services.google.given_name': 1
            limit: ContactsHandle.limit()
    
    contactsReady: ->
        ContactsHandle.ready()
    
    allContactsLoaded: ->
        ContactsHandle.ready() and Meteor.users.find().count() < ContactsHandle.loaded()

Template.contacts.events
    'click .load-more': (e) ->
        e.preventDefault()
        ContactsHandle.loadNextPage()

Template.contact.events
    "click .record": (e) ->
        console.log("record click", @_id)
        Router.go 'viewContact',
            _id: @_id 