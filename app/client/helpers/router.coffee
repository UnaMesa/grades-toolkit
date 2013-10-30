
Router.configure
    layoutTemplate: 'layout'
    loadingTemplate: 'loading'
    notFoundTemplate: 'notFound'

Router.map ->
    @route 'home',
      path: '/'
      data:
        title: 'Home'

    @route 'cases',
      data:
        title: 'Cases'
        doNewRecord: true
        recordName: 'Case'
        newRecordPath: 'newCase'

    @route 'newCase',
      path: 'cases/new'
      data:
        title: 'New Case'

    @route 'viewCase',
      path: 'cases/:_id'
      before: ->
        Session.set('currentCaseId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Posts.findOne(@params._id)
        data.title = "#{data.name}"
        data.goBackPath = "cases"
        data

    @route 'editCase',
      path: 'cases/edit/:_id'
      before: ->
        Session.set('currentCaseId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "Edit Case #{data.name}"
        data.goBackPath = "cases"
        data

    @route 'caseNotes',
      path: 'cases/notes/:_id'
      before: ->
        Session.set('currentCaseId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "#{data.name} Case Notes"
        data.goBackPath = "cases"
        data

    @route 'info',
      data:
        title: 'Information'

    @route 'contacts',
      data:
        title: 'Contacts'

    @route 'messages',
      data:
        title: 'Messages'

    @route 'settings',
      data:
        title: 'Settings'

    @route 'googleDocs',
      path: '/googledocs'
      data:
        title: 'Google Docs'

    @route 'newGoogleDoc',
      path: '/googledocs/new'
      data:
        title: 'Create Google Doc'

mustBeSignedIn = ->
  if not Meteor.user()
    if Meteor.loggingIn()
      @render("loading")
    else
      @render("accessDenied")
    @stop()


# this hook will run on almost all routes
Router.before mustBeSignedIn, except: ['home']

# this hook will run on all routes
Router.before ->
  CoffeeAlerts.clearSeen()
  

Router.after  ->
  Session.set('path', location.pathname)
