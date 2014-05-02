#
#  Functions to save BID/MOU to google Drive
#


@GoogleDriveSaveBID = (rec) ->
  console.log("Send HTML or BID to Google Drive")
  gDrive.findOrCreateFolder 'Cases', 'root', (resp) ->
    if resp.error?
      console.log("Error on findOrCreate cases folder", resp.error)
      CoffeeAlerts.error("Could not access Cases folder #{resp.error.message}")
    else
      gDrive.findOrCreateFolder 'BIDs', resp.id, (resp) ->
        if resp.error?
          console.log("Error on findOrCreate BIDs folder", resp.error)
          CoffeeAlerts.error("Could not access BIDs folder ")
        else
          # Fix links for download
          rec.html = rec.html.replace( /\/\/netdna.bootstrapcdn.com/g,'http://netdna.bootstrapcdn.com')
          # Create File
          gDrive.createFile rec.title, rec.html, resp.id, 'text/html', (resp) ->
            if resp.error?
              console.log("Error on create BID", resp.error)
              CoffeeAlerts.error("Could not save BID to Google Drive")
            else
              CoffeeAlerts.success("Saved BID to Google Dirve #{}")
              console.log("Google Create Doc", resp.webContentLink)
              Meteor.call "sendCaseEmail", "BID", rec.id, resp.webContentLink, rec.link, (error, result) ->
                if error
                  console.log("Error sending BID Email", error)
                  CoffeeAlerts.error("Error sending BID Email")

                                

@GoogleDriveSaveMOU = (rec) ->
  console.log("Send HTML or MOU to Google Drive")
  gDrive.findOrCreateFolder 'Cases', 'root', (resp) ->
    if resp.error?
      console.log("Error on findOrCreate cases folder", resp.error)
      CoffeeAlerts.error("Could not access Cases folder #{resp.error.message}")
    else
      gDrive.findOrCreateFolder 'MOUs', resp.id, (resp) ->
        if resp.error?
          console.log("Error on MOUs findOrCreate", resp.error)
          CoffeeAlerts.error("Could not access MOUs folder")
        else
          # Fix links for download
          rec.html = rec.html.replace( /\/\/netdna.bootstrapcdn.com/g,'http://netdna.bootstrapcdn.com')
          # Create File
          gDrive.createFile rec.title, rec.html, resp.id, 'text/html', (resp) ->
            if resp.error?
              console.log("Error on create MOU", resp.error)
              CoffeeAlerts.error("Could not save MOU to Google Drive")
            else
              CoffeeAlerts.success("Saved MOU to Google Dirve #{}")
              console.log("Google Create Doc", resp.webContentLink)
              Meteor.call "sendCaseEmail", "MOU", rec.id, resp.webContentLink, rec.link, (error, result) ->
                if error
                  console.log("Error sending MOU Email", error)
                  CoffeeAlerts.error("Error sending MOU Email")




