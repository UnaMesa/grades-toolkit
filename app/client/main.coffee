
Template.layout.rendered = ->
    if /mobile/i.test(navigator.userAgent)
        FastClick.attach document.body
    

Meteor.startup ->
    console.log("Meteor Startup on client")
    AccountsEntry.config
        #logo: 'img/bia.png'
        privacyUrl: '/privacy-policy'
        termsUrl: '/terms-of-use'
        homeRoute: '/'
        dashboardRoute: '/'
        profileRoute: 'profile'
        showSignupCode: true
        passwordSignupFields: 'USERNAME_AND_EMAIL'

