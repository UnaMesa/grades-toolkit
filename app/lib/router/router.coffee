
Router.configure
    layoutTemplate: 'layout'
    loadingTemplate: 'loading'
    notFoundTemplate: 'notFound'
    #disableProgressTick : true
    disableProgressSpinner : true

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
        Session.set('messageTagFilter', 'case')
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "Edit Case"
        data.goBackPath = "viewCase"
        data

    @route 'editCasePhoto',
      path: 'cases/photo/edit/:_id'
      template: 'photoEditor'
      before: ->
        Session.set('currentRecordId', @params._id)
        Session.set('messageTagFilter', 'case')
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "Edit Photo"
        data.goBackPath = "editCase"
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

    @route 'bid',
      path: "cases/bid/:_id"
      before: ->
        Session.set('currentRecordId', @params._id)
        Session.set("bidAttendees", null)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "BID for #{data.name}"
        data.goBackPath = "viewCase"
        data

    @route 'generatedBid',
      path: "cases/bid/:_id/generated"
      layoutTemplate: 'empty'
      before: ->
        Session.set('currentRecordId', @params._id)
        Session.set("bidAttendees", null)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "BID for #{data.name}"
        data

    @route 'mou',
      path: "cases/mou/:_id"
      before: ->
        Session.set('currentRecordId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "MOU for #{data.name}"
        data.goBackPath = "viewCase"
        data

    @route 'generatedMou',
      path: "cases/mou/:_id/generated"
      before: ->
        Session.set('currentRecordId', @params._id)
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "MOU for #{data.name}"
        data.goBackPath = "viewCase"
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

    @route 'editFamily',
      path: 'families/edit/:_id'
      before: ->
        Session.set('currentRecordId', @params._id)
        Session.set('messageTagFilter', 'family')
      waitOn: ->
        Meteor.subscribe('singleFamily', @params._id)
      data: ->
        data = Families.findOne(@params._id)
        data.title = "Edit Family"
        data.goBackPath = "viewFamily"
        data

    @route 'editFamilyPhoto',
      path: 'families/photo/edit/:_id'
      template: 'photoEditor'
      before: ->
        Session.set('currentRecordId', @params._id)
        Session.set('messageTagFilter', 'family')
      waitOn: ->
        Meteor.subscribe('singleFamily', @params._id)
      data: ->
        data = Families.findOne(@params._id)
        data.title = "Edit Photo"
        data.goBackPath = "editFamily"
        data

    @route 'familyPhotos',
      path: 'family/:_id/photos'
      #layoutTemplate: 'layoutInverse'
      before: ->
        $('body')?.addClass("photoBody")
        Session.set('currentRecordId', @params._id)
        Session.set('messageTagFilter', 'family')
      waitOn: ->
        Meteor.subscribe('singleFamily', @params._id)
        #@FamilyPhotosHandle = Meteor.subscribeWithPagination('familyPhotos', @params._id, 20)
      data: ->
        data = Families.findOne(@params._id)
        data.title = "Family Photos"
        data.goBackPath = "viewFamily"  # Got to get _id into this....
        data

    @route 'casePhotos',
      path: 'case/:_id/photos'
      #layoutTemplate: 'layoutInverse'
      before: ->
        $('body')?.addClass("photoBody")
        Session.set('currentRecordId', @params._id)
        Session.set('messageTagFilter', 'case')
      waitOn: ->
        Meteor.subscribe('singleCase', @params._id)
        #@CasePhotosHandle = Meteor.subscribeWithPagination('casePhotos', @params._id, 20)
      data: ->
        data = Cases.findOne(@params._id)
        data.title = "Case Photos"
        data.goBackPath = "viewCase"  # Got to get _id into this....
        data
      

    @route 'contacts',
      data:
        title: 'Contacts'

    @route 'viewContact',
      path: 'contacts/:_id'
      before: ->
        Session.set('currentRecordId', @params._id)
        Session.set('messageTagFilter', 'user')
      #waitOn: ->
      #  Meteor.subscribe('singleUser', @params._id)
      data: ->
        data = Meteor.users.findOne(@params._id)
        data.title = data.profile.name
        data.goBackPath = "contacts"
        data

    @route 'messages',
      data:
        title: 'Messages'

    @route 'docs',
      data:
        title: 'Documents'


    @route 'settings',
      data:
        title: 'Settings'


    @route 'googleAuth',
      data:
        title: "Google Drive"

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

    #
    #  Server Side
    #

    @route 'serverGenerateBID',
      where: 'server'
      path: "cases/bid/:_id/server_generate"
      action: ->
        @response.writeHead 200, 
          'Content-Type': 'text/html'
        @response.write('Show Generated BID')
        @response.end()
        console.log("Generated BID for ", @params._id, @userId)

mustBeSignedIn = ->
  if not user = Meteor.user()
    if Meteor.loggingIn()
      @render("loading")
    else
      @render("accessDenied")
    @stop()
  else
    # Token Testing  REMOVE FOR FLIGHT
    console.log('clientToken expires_in', gapi?.auth?.getToken?()?.expires_in)
    console.log('loginToken expires', moment(user.services?.google?.expiresAt).format('llll'))
  
setTags = ->
  if user = Meteor.user()
    tags = {}
    tags[user.tag] =
      type: 'user'
      _id: user._id
      tag: user.tag
      name: user.profile.name
    Session.set("tags", tags)

cleanUp = ->
  $('body').removeClass("photoBody")
  CoffeeAlerts.clearSeen()
  Session.set('messageTagFilter', null)
  Session.set('currentRecordId', null)

googleDriveAuthorize = ->
  #console.log("Check google auth", gDrive)
  if Meteor.user()
    if not gDrive.userDeclined and not gDrive.authorized() and not gDrive.authorizing()
      @render("googleAuth")
      @stop()


# this hook will run on almost all routes
Router.before mustBeSignedIn, except: ['home', 'serverGenerateBID']

Router.before setTags, except: ['serverGenerateBID']

# this hook will run on all routes
Router.before cleanUp, except: ['serverGenerateBID']
 
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

setPath = ->
  Session.set('path', location.pathname)

# this hook will run on almost all routes
#Router.after googleDriveAuthorize, except: []

Router.after addPageTag, except: ['home','serverGenerateBID']

Router.after  setPath, except: ['serverGenerateBID']
 

#Router.after ->
#  addPageTag()
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





