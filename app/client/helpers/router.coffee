
Router.configure
    layoutTemplate: 'layout'
    loadingTemplate: 'loading'
    notFoundTemplate: 'notFound'

Router.map ->
    @route 'home',
      path: '/'

      before: ->
        if not Meteor.user()
          @render("login")
          @stop();

      data:
        title: 'Grades'

    @route 'login',
      path: '/login',
      layoutTemplate: 'loginLayout',

    @route 'cases',
      data:
        title: 'Cases'
        recordName: 'Case'
        newRecordPath: 'newCase'

    @route 'newCase',
      path: 'cases/new'
      data:
        title: 'New Case'
        goBackPath: "cases"

    @route 'viewCase',
      path: 'cases/:_id'
      before: ->
        Session.set('currentCaseId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "Case"
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

    @route 'bid',
      path: "cases/bid/:_id"
      before: ->
        Session.set('currentCaseId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "Create BID"
        data.goBackPath = "viewCase"
        console.log("data", data)
        data

    @route 'mou',
      path: "cases/mou/:_id"
      before: ->
        Session.set('currentCaseId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "Create MOU"
        data.goBackPath = "viewCase"
        data

    @route 'docs',
      data:
        title: 'Documents'

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

    @route 'cryptoTest',
      path: '/crypto/test'
      data:
          title: "Key Generation Test"


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
  
Router.after ->
  console.log("URL:",document.URL)
  if /mobile/i.test(navigator.userAgent)
    #
    # Trying to hide browers bar on iOS.  TODO: Get this to work
    #
    Meteor.setTimeout ->
      # Does not pull this off....
      window.scrollTo(0, 1)
      console.log("Scroll to top?", window)
    , 500

Router.after  ->
  Session.set('path', location.pathname)



