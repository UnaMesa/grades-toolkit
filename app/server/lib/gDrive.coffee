#
#  GDrive Functions for the server
#

#
#  Get Info on Family Resorces File and sync to here if it changes
#  Check every N seconds...
#

###

 This is using the google-oauth-jwt Node NPM
    https://github.com/extrabacon/google-oauth-jwt

Uses Google OAuth 2.0 for server-to-server interactions, 
allowing secure use of Google APIs without URL redirects and authorization prompts.

###


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


gDrive.getFileList = (folderId) ->
    gDrive.init()
    url = "https://www.googleapis.com/drive/v2/files"
    
    if folderId
        url += '?q=' + encodeURIComponent("'#{folderId}' in parents")
    
    # Must bind the callback to meteor !!!
    callback =  Meteor.bindEnvironment (err, res, body) ->
        if err
            throw err
        body = JSON.parse(body)
        if body.kind is 'drive#fileList' and body.items?
            gDrive._fileList = body.items
            console.log("Received file list")
            for file in gDrive._fileList
                Links.upsert
                    id: file.id
                ,
                    file
                
                #console.log("gDrive File: #{file.title} (#{file.kind})", file.id, file.mimeType)
                #console.log(file)
                #console.log(" selfLink", file.selfLink)
                #console.log(" alternateLink", file.alternateLink)
                #console.log(" iconLink", file.iconLink)

    gDrive._request
        url: url
        jwt: GoogleJWT
    , callback




gDrive.fileList = ->
    gDrive._fileList


gDrive.getSpreadSheetList = ->
    console.log("getSpreadSheetList")
    gDrive.init()
    gDrive._request
        url: "https://spreadsheets.google.com/feeds/spreadsheets/private/full"
        jwt: GoogleJWT
    , (err, res, body) ->
        console.log("getSpreadSheetList return")
        if err
            console.log("getSpreadSheetList Error:", err)
        else
            console.log("getSpreadSheetList", body)
            #console.log("getSpreadSheetList", JSON.parse(body))


gDrive.getSpreadSheetWorkSheetList = (key) ->
    console.log("getSpreadSheetWorkSheetList")
    gDrive.init()
    gDrive._request
        url: "https://spreadsheets.google.com/feeds/worksheets/#{key}/private/full"
        jwt: GoogleJWT
    , (err, res, body) ->
        console.log("getSpreadSheetWorkSheetList return")
        if err
            console.log("getSpreadSheetWorkSheetList Error:", err)
        else
            console.log("getSpreadSheetWorkSheetList", body)
            #console.log("getSpreadSheetWorkSheetList", JSON.parse(body))


gDrive.baseUrl = (spreadsheetId, worksheetId) ->
    'https://spreadsheets.google.com/feeds/cells/' + spreadsheetId + '/' + worksheetId + '/private/full'


gDrive.getAndUpdateFamilyList = ->
    console.log("getAndUpdateFamilyList")
    gDrive.init()
    
    gDrive._request
        url: gDrive.baseUrl(GoogleFamilySpreadsheetId, GoogleFamilyWorksheetId) + '?alt=json'
        jwt: GoogleJWT
    , Meteor.bindEnvironment gDrive._updateFamilyList, (err) ->   # This works but need to understand
        console.log("getAndUpdateFamilyList Error", err)


gDrive._updateFamilyList = (err, res, body) ->
    if err
        throw err
    result = JSON.parse(body)
    
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
        if val["lastname"] is '__END__'
            break
        gDrive._families.push val

    # Might not want this for flight
    console.log("remove families")
    Families.remove({})

    #console.log("Updating family list from spreadsheet", gDrive._families)
    for family in gDrive._families 
        if family['lastname'] and family['firstname']
            if not family.tag or family.tag is ''
                tagString = family['lastname'].split('/')?.join(' ') + " " + family['firstname'].split('/').join(' ')
                # TODO: We should generate tags not the spreadsheet and update
                family.tag = createFamilyTag(tagString) 
            
            #console.log("Upsert", tagString, family.tag)
            
            Families.upsert 
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
    , Meteor.bindEnvironment gDrive.staleFamilyListCheck, (err) ->   # This works but need to understand
        console.log("checkFamilyList Error", err)


gDrive.staleFamilyListCheck = (err, res, body) ->
        if err
            throw err
        body = JSON.parse(body)
        if not body?.modifiedDate?
            console.log("Error no body modifiedDate on staleFamilyListCheck", body)
        else
            if moment(body.modifiedDate).isAfter(gDrive._familyListUpdated)
                console.log("Family data is stale!  Updating")
                gDrive.getAndUpdateFamilyList()



