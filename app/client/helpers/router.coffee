
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
        Session.set('currentRecordId', @params._id)
        Session.set('messageTagFilter', 'case')
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
        Session.set('currentRecordId', @params._id)
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
        Session.set('currentRecordId', @params._id)
        Session.set('messageTagFilter', 'case')
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "#{data.name} Case Notes"
        data.goBackPath = "cases"
        data

    @route 'families',
      data:
        title: "Families"

    @route 'viewFamily',
      path: 'families/:_id'
      before: ->
        Session.set('currentRecordId', @params._id)
        Session.set('messageTagFilter', 'family')
      waitOn: ->
        Meteor.subscribe('singleFamily', @params._id)
      data: ->
        data = Families.findOne(@params._id)
        data.title = "Family"
        data.goBackPath = "families"
        data

    @route 'bid',
      path: "cases/bid/:_id"
      before: ->
        Session.set('currentRecordId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "BID for #{data.name}"
        data.goBackPath = "viewCase"
        data

    @route 'mou',
      path: "cases/mou/:_id"
      before: ->
        Session.set('currentRecordId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "Create MOU for #{data.name}"
        data.goBackPath = "viewCase"
        data

    @route 'docs',
      data:
        title: 'Documents'

    @route 'googleAuth',
      data:
        title: "Google Drive"

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
  
setTags = ->
  if user = Meteor.user()
    tags = {}
    tags[user.tag] =
      type: 'user'
      _id: user._id
      tag: user.tag
      name: user.profile.name
    Session.set("tags", tags)

googleDriveAuthorize = ->
  #console.log("Check google auth", gDrive)
  if Meteor.user()
    if not gDrive.userDeclined and not gDrive.authorized() and not gDrive.authorizing()
      @render("googleAuth")
      @stop()

addPageTag = ->
  if Session.get('messageTagFilter')? and Session.get('currentRecordId')?
    #tags = Session.get("tags")
    #for tag in tags
    #  if tag._id is Session.get('currentRecordId')
    #    return
    tag =
      type: Session.get('messageTagFilter')
      _id: Session.get('currentRecordId')
    Meteor.call "getFullTag", tag, (error, tag) ->
      if not error? and tag?
        tags = Session.get("tags")
        tags[tag.tag] = tag
        Session.set("tags", tags)


# this hook will run on almost all routes
Router.before mustBeSignedIn, except: ['home']

Router.before setTags, except: []

# this hook will run on almost all routes
#Router.after googleDriveAuthorize, except: []

Router.after addPageTag, except: ['home']

# this hook will run on all routes
Router.before ->
  CoffeeAlerts.clearSeen()
  Session.set('messageTagFilter', null)
  Session.set('currentRecordId', null)
  

Router.after ->
  addPageTag()
### 
  if /mobile/i.test(navigator.userAgent)
    #
    # Trying to hide browers bar on iOS.  TODO: Get this to work
    #
    Meteor.setTimeout ->
      # Does not pull this off....
      window.scrollTo(0, 1)
      console.log("Scroll to top?", window)
    , 500
###

Router.after  ->
  Session.set('path', location.pathname)



