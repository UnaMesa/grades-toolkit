
Template.generatedMou.helpers
  today: ->
    moment().format('LL')

  dateOfCustody: ->
    moment(MOU.dataOfCustody).format('LL')

  socialWorkerName: ->
    console.log("name", Meteor.user()?.services?.google)
    google = Meteor.user()?.services?.google
    if Meteor.user()?.profile.name?
      Meteor.user()?.profile.name
    else if google
      name = google.name or "#{google.given_name} #{google.family_name}"
    else
      "No Name"