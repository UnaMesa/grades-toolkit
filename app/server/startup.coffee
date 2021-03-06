
@familyCheckIntervalId = null

Meteor.startup ->
  console.log("Server Startup")

  #gDrive.getSpreadSheetList()
  #gDrive.getSpreadSheetWorkSheetList(GoogleFamilySpreadsheetId)
  #gDrive.getSpreadSheetWorkSheetList(GoogleFamilySpreadsheetOldId)
  
  gDrive.getAndUpdateFamilyList()

  # Do with a push notification from Google but requires a valie SSL cert!!!
  # Check the spreadsheet every N seconds 
  familyCheckIntervalId = Meteor.setInterval(gDrive.checkFamilyList, 60000)

  console.log("Get Docs Links List")
  gDrive.getDocLinks()

  # Update links once an hour
  Meteor.setInterval(gDrive.getDocLinks, 1000*60*60)

  Links._ensureIndex
    id: 1
  ,
    unique: true 

  #
  #  For now this is hard coded...
  #
  validEmails = [
    'barbara.joyal@state.vt.us'
    'deb.caruso@state.vt.us'
    'julie.lamare@state.vt.us'
    'julie.kozlowski@state.vt.us'
    'alyssa.mullen@state.vt.us'
    'erin.longchamp@state.vt.us'
    'anna.kallman@state.vt.us'
    'julianna.stemp@state.vt.us'
    'ken.hammond@state.vt.us'
    'tina.lapier@state.vt.us'
    'kerrie.johnson@state.vt.us'
    'kathy.shackett@state.vt.us'
    'margaret.burbank@state.vt.us'
    'joan.rock@state.vt.us'
    'Tracey.Lamoureux@state.vt.us'
    'gregwolff@unamesa.org'
    'tim@pfafman.com'
    'amandaroselevin@gmail.com'
  ]

  admins = [
    'joan.rock@state.vt.us'
    'gregwolff@unamesa.org'
    'tim@pfafman.com'
  ]

  if validEmails.length isnt ValidUsers.find().count()
    console.log("Set up Valid Emails Table")
    ValidUsers.remove({})
    for email in validEmails
      email = email.toLowerCase()
      ValidUsers.insert
        email: email
        admin: email in admins

  for email in admins
    Meteor.users.update
      "services.google.email": email
    ,
      $set:
        admin: true






