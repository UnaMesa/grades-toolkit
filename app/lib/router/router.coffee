
Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  notFoundTemplate: 'notFound'
  #disableProgressTick : true
  disableProgressSpinner : true

Router.map ->
  @route 'accessDenied'

  @route 'home',
    path: '/'
    onBeforeAction: (pause) ->
      if not Meteor.user()
        @render("login")
        pause();
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
    onBeforeAction: ->
      console.log("viewCase:onBeforeAction", @params._id)
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'case')
    waitOn: ->
      Meteor.subscribe('singleCase', @params._id)
    data: ->
      console.log("viewCase:data", @params._id)
      data = Cases.findOne(@params._id) or {}
      data.title = "Case"
      data.goBackPath = "cases"
      data

  @route 'editCase',
    path: 'cases/edit/:_id'
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'case')
    waitOn: ->
      Meteor.subscribe('singleCase', @params._id)
    data: ->
      data = Cases.findOne(@params._id) or {}
      data.title = "Edit Case"
      data.goBackPath = "viewCase"
      data

  @route 'editCasePhoto',
    path: 'cases/photo/edit/:_id'
    template: 'photoEditor'
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'case')
    waitOn: ->
      Meteor.subscribe('singleCase', @params._id)
    data: ->
      data = Cases.findOne(@params._id) or {}
      data.title = "Edit Photo"
      data.goBackPath = "editCase"
      data

  @route 'caseNotes',
    path: 'cases/notes/:_id'
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'case')
    waitOn: ->
      Meteor.subscribe('singleCase', @params._id)
    data: ->
      data = Cases.findOne(@params._id) or {}
      name = data?.name
      data.title = "#{name} Case Notes"
      data.goBackPath = "cases"
      data

  @route 'bid',
    path: "cases/bid/:_id"
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
      Session.set("bidAttendees", null)
    waitOn: ->
      Meteor.subscribe('singleCase', @params._id)
    data: ->
      data = Cases.findOne(@params._id) or {}
      data.title = "BID for #{data.name}"
      data.goBackPath = "viewCase"
      data

  @route 'generatedBid',
    path: "cases/bid/:_id/generated"
    layoutTemplate: 'empty'
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
      Session.set("bidAttendees", null)
    waitOn: ->
      Meteor.subscribe('singleCase', @params._id)
    data: ->
      data = Cases.findOne(@params._id) or {}
      data.title = "BID for #{data.name}"
      data


  @route 'downloadBid',
    path: "cases/bid/pdf/:fileId"
    #layoutTemplate: 'empty'
    action: ->
      console.log("Get download File", @params.fileId)
      fileId = @params.fileId
      Meteor.call "getBid", @params.fileId, (error, result) =>
        if error
          console.log("Error geting BID", error)
          CoffeeAlerts.error("Error geting BID: #{error.reason}")
        else if result?
          bidWindow = window.open("")
          if not bidWindow?
            # Try in same frame
            bidWindow = window.open("","_self")
          if bidWindow?
            bidWindow.document.write(result)
            if false
              console.log("print BID")
              bidWindow.print()
          else
            CoffeeAlerts.error("Error geting BID, you need pop up windows enabled for this to work")
        
          #file = result
          #blob = new Blob [file],
          #  type: "text/html"
          #console.log("Sending download", fileId)
          #saveAs(blob, fileId + ".html")
        else
          CoffeeAlerts.error("Error geting BID, could not find file")
        
        Router.go 'viewCase', 
          _id: @params.case
  
          
  @route 'downloadMou',
    path: "cases/mou/pdf/:fileId"
    #layoutTemplate: 'empty'
    action: ->
      console.log("Get download File", @params.fileId)
      fileId = @params.fileId
      Meteor.call "getMou", @params.fileId, (error, result) =>
        if error
          CoffeeAlerts.error("Error geting MOU: #{error.reason}")
        else if result?
          mouWindow = window.open("")
          if not mouWindow?
            # Try in same frame
            mouWindow = window.open("","_self")
          if mouWindow?
            mouWindow.document.write(result)
            if false
              console.log("print MOU")
              mouWindow.print()
          else
            CoffeeAlerts.error("Error geting MOU, you need pop up windows enabled for this to work")
        
          #file = result
          #blob = new Blob [file],
          #  type: "text/html"
          #console.log("Sending download", fileId,  file.length)
          #saveAs(blob, fileId + ".html")
        else
          CoffeeAlerts.error("Error geting MOU, could not find file")
        
        Router.go 'viewCase', 
          _id: @params.case
        

  @route 'mou',
    path: "cases/mou/:_id"
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
    waitOn: ->
      Meteor.subscribe('singleCase', @params._id)
    data: ->
      data = Cases.findOne(@params._id) or {}
      data.title = "MOU for #{data.name}"
      data.goBackPath = "viewCase"
      data

  @route 'generatedMou',
    path: "cases/mou/:_id/generated"
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
    waitOn: ->
      Meteor.subscribe('singleCase', @params._id)
    data: ->
      data = Cases.findOne(@params._id) or {}
      data.title = "MOU for #{data.name}"
      data.goBackPath = "viewCase"
      data

  @route 'families',
    data:
      title: "Families"

  @route 'viewFamily',
    path: 'families/:_id'
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'family')
    waitOn: ->
      Meteor.subscribe('singleFamily', @params._id)
    data: ->
      data = Families.findOne(@params._id) or {}
      data.title = "Family"
      data.goBackPath = "families"
      data

  @route 'editFamily',
    path: 'families/edit/:_id'
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'family')
    waitOn: ->
      Meteor.subscribe('singleFamily', @params._id)
    data: ->
      data = Families.findOne(@params._id) or {}
      data.title = "Edit Family"
      data.goBackPath = "viewFamily"
      data

  @route 'editFamilyPhoto',
    path: 'families/photo/edit/:_id'
    template: 'photoEditor'
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'family')
    waitOn: ->
      Meteor.subscribe('singleFamily', @params._id)
    data: ->
      data = Families.findOne(@params._id) or {}
      data.title = "Edit Photo"
      data.goBackPath = "editFamily"
      data

  @route 'familyPhotos',
    path: 'family/:_id/photos'
    #layoutTemplate: 'layoutInverse'
    onBeforeAction: ->
      $('body')?.addClass("photoBody")
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'family')
    waitOn: ->
      Meteor.subscribe('singleFamily', @params._id)
      #@FamilyPhotosHandle = Meteor.subscribeWithPagination('familyPhotos', @params._id, 20)
    data: ->
      data = Families.findOne(@params._id) or {}
      data.title = "Family Photos"
      data.goBackPath = "viewFamily"  # Got to get _id into this....
      data

  @route 'casePhotos',
    path: 'case/:_id/photos'
    #layoutTemplate: 'layoutInverse'
    onBeforeAction: ->
      $('body')?.addClass("photoBody")
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'case')
    waitOn: ->
      Meteor.subscribe('singleCase', @params._id)
      #@CasePhotosHandle = Meteor.subscribeWithPagination('casePhotos', @params._id, 20)
    data: ->
      data = Cases.findOne(@params._id) or {}
      data.title = "Case Photos"
      data.goBackPath = "viewCase"  # Got to get _id into this....
      data
    

  @route 'contacts',
    data:
      title: 'Contacts'

  @route 'viewContact',
    path: 'contacts/:_id'
    onBeforeAction: ->
      Session.set('currentRecordId', @params._id)
      Session.set('messageTagFilter', 'user')
    #waitOn: ->
    #  Meteor.subscribe('singleUser', @params._id)
    data: ->
      data = Meteor.users.findOne(@params._id) or {}
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

  ###
  @route 'serverGenerateBID',
    where: 'server'
    path: "cases/bid/:_id/server_generate"
    action: ->
      @response.writeHead 200, 
        'Content-Type': 'text/html'
      @response.write('Show Generated BID')
      @response.end()
      console.log("Generated BID for ", @params._id, @userId)
  ###

mustBeSignedIn = (pause) ->
  if not user = Meteor.user()
    if Meteor.loggingIn()
      @render("loading")
    else
      #AccountsEntry.signInRequired(@)
      @render("accessDenied")
    pause()
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

googleDriveAuthorize = (pause) ->
  #console.log("Check google auth", gDrive)
  if Meteor.user()
    if not gDrive.userDeclined and not gDrive.authorized() and not gDrive.authorizing()
      @render("googleAuth")
      pause()


# Google Only Log In
# this hook will run on almost all routes
Router.onBeforeAction mustBeSignedIn, except: ['home', 'serverGenerateBID']

# If Adding Passwords
# this hook will run on all routes
#Router.onBeforeAction mustBeSignedIn, 
#    except: ['entrySignIn', 'entrySignUp', 'entryForgotPassword', 'entryResetPassword', 'entryStart', 'terms', 'privacy']


Router.onBeforeAction setTags, except: ['serverGenerateBID']

Router.onBeforeAction "loading"

# this hook will run on all routes
Router.onRun cleanUp, except: ['serverGenerateBID']
 
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
#Router.onAfterAction googleDriveAuthorize, except: []

Router.onAfterAction addPageTag, except: ['home','serverGenerateBID']

Router.onAfterAction  setPath, except: ['serverGenerateBID']
 

#Router.onAfterAction ->
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





