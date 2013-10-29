
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
  CoffeeErrors.clearSeen()

Router.after  ->
    Session.set('path', location.pathname)
