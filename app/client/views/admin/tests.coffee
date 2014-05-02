

theFolder = "Cases"
subFolders = ["BIDs","MOUs"]


searchCallback = (resp) ->
  console.log("searchCallback", resp)
  if resp.error?
    console.log("Error on search", resp.error)
    Session.set("testsFoundFile", "error")
  else
    Session.set("testsFoundFile", "exists")
    createSubFolders(resp.id)
  

createSubFolders = (parent) ->
  for folder in subFolders
    console.log("create or find", folder)
    gDrive.findOrCreateFolder folder, parent, (resp) ->
      if resp.error
        console.log("createSubFolders: Error", resp)
      else
        console.log("Created or found", theFolder, resp)
        Session.set("#{resp?.title}Folder", "exists")
        gDrive.createFile("Test.txt","This is a test", resp.id)
        

Template.tests.created = ->
  Session.set("testsFoundFile", "")
  Session.set("BIDsFolder", "")
  Session.set("MOUsFolder", "")
  
  gDrive.reset()
  gDrive.init()
  gDrive.findOrCreateFolder(theFolder, 'root', searchCallback)



Template.tests.helpers
  
  authorized: ->
    if gDrive.authorized()
      "Authorized"
    else
      "FAIL"

  casesFolder: ->
    Session.get("testsFoundFile")

  bidsFolder: ->
    Session.get("BIDsFolder")

  mousFolder: ->
    Session.get("MOUsFolder")



