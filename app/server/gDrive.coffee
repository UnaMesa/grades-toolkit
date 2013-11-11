#
#  GDrive Functions
#

#
#  Get Info on Family Resorces File and sync to here if it changes
#  Check every 60 seconds...
#


@gDrive = {}

gDrive.authTest = ->
    # Test Google Server to Server Authentication
    #  Requires a PEM file in the private directory

    request = GoogleServerAuth.requestWithJWT()

    request
        url: "https://www.googleapis.com/drive/v2/files"
        jwt: GoogleJWTWithScopes
    , (err, res, body) ->
        console.log "Google Drive filelist for this account"
        console.log JSON.parse(body)


gDrive.getFamilyList = ->
    
    #console.log("JWT", GoogleJWT)
    
    GoogleSpreadsheet.create
        debug: true
        oauth: GoogleJWT
        #spreadsheetName: 'Family Resources' 
        spreadsheetId: '0Av9gAHThBTkKdFFmSG11WTRhc1NwTk1iOHBDanpRRUE'
        #worksheetName: "Families"
        worksheetId: 'od6'
        callback: (err, spreadsheet) ->
            console.log("call back")
            if err
                throw err

            spreadsheet.receive (err, rows, info) ->
                if(err) 
                    throw err
                else
                    console.log("Found rows:", rows)
                    console.log("info", info)



