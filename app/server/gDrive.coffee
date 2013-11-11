#
#  GDrive Functions for the server
#

#
#  Get Info on Family Resorces File and sync to here if it changes
#  Check every N seconds...
#

#
#  TODO: 
#   We are currently using the node-edit-google-spreadsheet npm.
#   This does not use the token cache in google-awt-oauth.  Looks
#   Like it would be easy to encorporate this in.  Probably write
#   a atmosphere package that has the google-awt-oauth but we write
#   the parts of the google spreadsheet api we need.  For IMHO the 
#   spreadheeet package has a fair amount of fluff.
#


@gDrive = {}

gDrive._request = null

gDrive._fileList = null

gDrive._families = []

gDrive._familyListUpdated = null

gDrive.init = ->
    if not gDrive?._request?
        gDrive._request = GoogleServerAuth.requestWithJWT()

gDrive.authTest = ->
    # Test Google Server to Server Authentication
    #  Requires a PEM file in the private directory

    gDrive.init()

    gDrive._request
        url: "https://www.googleapis.com/drive/v2/files"
        jwt: GoogleJWT
    , (err, res, body) ->
        console.log "Google Drive filelist for this account"
        console.log JSON.parse(body)


gDrive.getFileList = ->
    gDrive.init()
    gDrive._request
        url: "https://www.googleapis.com/drive/v2/files"
        jwt: GoogleJWT
    , (err, res, body) ->
        if err
            throw err
        body = JSON.parse(body)
        if body.kind is 'drive#fileList' and body.items?
            gDrive._fileList = body.items
            console.log("Received file list")
            console.log(gDrive._fileList)

gDrive.fileList = ->
    gDrive._fileList

gDrive.baseUrl = (spreadsheetId, worksheetId) ->
    'https://spreadsheets.google.com/feeds/cells/' + spreadsheetId + '/' + worksheetId + '/private/full'

gDrive.getAndUpdateFamilyList = ->
    gDrive.init()
    
    gDrive._request
        url: gDrive.baseUrl(GoogleFamilySpreadsheetId, GoogleFamilyWorksheetId) + '?alt=json'
        jwt: GoogleJWT
    , Meteor.bindEnvironment gDrive._updateFamilyList, (err) ->   # This works but need to understand
        throw err


gDrive._updateFamilyList = (err, res, body) ->
        if err
            throw err
        result = JSON.parse(body)
        #console.log(result)

        entries = result.feed?.entry || []
        
        rawData = {}
        headers = {}
        for entry in entries
            cell = entry.gs$cell

            if (cell.row is "1")
                headers[cell.col] = cell.inputValue.toLowerCase()
            else
                if not rawData[cell.row]
                    rawData[cell.row] = {}
                rawData[cell.row][headers[cell.col]] = cell.inputValue

        # TODO: Find a way to get this into an array from the start
        gDrive._families = []
        for key, val of rawData
            gDrive._families.push val

        console.log("Updating family list from spreadsheet", gDrive._families)
        for family in gDrive._families 
            #console.log("Update", family)

            # TODO: We should generate tags not the spreadsheet and update
            family.tag = family.tag.toLowerCase()

            Families.update 
                tag: family.tag
            ,
                $set: family
            ,
                upsert: true
            , (error, result) ->
                if error
                    console.log("Error upserting family", error)

        gDrive._familyListUpdated = moment()

gDrive.checkFamilyList = ->
    gDrive.init()
    gDrive._request
        url: "https://www.googleapis.com/drive/v2/files/" + GoogleFamilySpreadsheetId 
        jwt: GoogleJWT
    , (err, res, body) ->
        if err
            throw err
        body = JSON.parse(body)
        if moment(body.modifiedDate).isAfter(gDrive._familyListUpdated)
            console.log("Family data is stale!  Updating")
            gDrive.getAndUpdateFamilyList()



