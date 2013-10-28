
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



mustBeSignedIn = ->
  if not Meteor.user()
    if Meteor.loggingIn()
      @render("loading")
    else
      @render("accessDenied")
    @stop()


# this hook will run on almost all routes
Router.before mustBeSignedIn, except: ['home']

Router.after  ->
    Session.set('path', location.pathname)
