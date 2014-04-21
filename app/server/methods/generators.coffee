#
#  Generate MOUs and BIDs
#

fs     = Npm.require('fs')
child  = Npm.require('child_process')

UPLOAD_DIR = '/var/spool/grades/'

console.log("generators")

documentsUsedForBid = (rec) ->
  rows = []
  row = []
  for val in BID.documentsUsed
    data =
      key: val
    if rec.BID?.documentsUsed and val in rec.BID.documentsUsed
      data.checked = "check-"
    row.push(data)
    if row.length is 2
      rows.push(row)
      row = []
  if row.length is 1
    rows.push(row)
  rows


considerations = (rec) ->
  considerations = []
  index = 0
  for consideration in @BID.considerations
    data = _.clone(consideration)
    index++
    data.index = index
    if data.helpBlock
      data.helpText = "<ul>"
      for help in data.helpBlock
        data.helpText +=  '<li>' + help + '</li>';
      data.helpText += "</ul>"
    if rec?.BID?.considerations
      for theCons in rec.BID.considerations
        if theCons.key is data.key
          data.factors = theCons.factors
          switch theCons.yesNo
            when 'yes'
              data.yes = "check-"
            when 'no'
              data.no = "check-"
          break
    considerations.push(data)
  
  considerations


stayAtCurrentSchool = (rec) ->
  rec.BID?.teamRecommendation is 'stayAtCurrentSchool'
    
moveToNewSchool = (rec) ->
  rec.BID?.teamRecommendation is 'moveToNewSchool'

teamDisagrees = (rec) ->
  rec.BID?.teamRecommendation is 'teamDisagrees'


currentSchool = (rec) ->
  if rec.BID?.teamRecommendation is 'stayAtCurrentSchool'
    rec.BID.schoolToAttend
  else
    " &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; "

currentSUSD = (rec) ->
  if rec.BID?.teamRecommendation is 'stayAtCurrentSchool'
    rec.BID.susd
  else
    " &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; "

newSchool = (rec) ->
  if rec.BID?.teamRecommendation is 'moveToNewSchool'
    rec.BID.schoolToAttend
  else
    " &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; "

newSUSD = (rec) ->
  if rec.BID?.teamRecommendation is 'moveToNewSchool'
    rec.BID.susd
  else
    " &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; "

otherDocumentsUsed = (rec) ->
  rec.BID?.otherDocumentsUsed or "&nbsp; &nbsp; &nbsp; -- NONE -- "


toArrayBuffer = (buffer) ->
  ab = new ArrayBuffer(buffer.length)
  view = new Uint8Array(ab)
  i = 0
  while i < buffer.length
    view[i] = buffer[i]
    ++i
  ab

Meteor.methods
  
  generateBid: (id) ->
    console.log("generateBid", id)
    user = Meteor.user()
    # ensure the user is logged in
    throw new Meteor.Error(401, "Need to be logged in")  unless user

    theCase = Cases.findOne(id)

    if theCase?
      theCase.bidDate = moment().format('LL')
      
      theCase.documentsUsedForBid = documentsUsedForBid?(theCase)
      theCase.considerations      = considerations?(theCase)
      theCase.stayAtCurrentSchool = stayAtCurrentSchool?(theCase)
      theCase.moveToNewSchool     = moveToNewSchool?(theCase)
      theCase.teamDisagrees       = teamDisagrees?(theCase)
      theCase.currentSchool       = currentSchool?(theCase)
      theCase.currentSUSD         = currentSUSD?(theCase)
      theCase.newSchool           = newSchool?(theCase)
      theCase.newSUSD             = newSUSD?(theCase)

      console.log("Do HTML")
      html = Handlebars.templates['generatedBid'](theCase)

      if html?
        fileId = moment().format('YYYYMMDD_HHmmss') + '_' + id
        htmlFile = UPLOAD_DIR + 'bids/' + fileId+ '.html'
        pdfFile  = UPLOAD_DIR + 'bids/' + fileId + '.pdf'

        fs.writeFileSync(htmlFile, html)
        
        toPdf = child.spawn "wkhtmltopdf", [htmlFile, pdfFile]
        toPdf.stdout.setEncoding('utf8');
        toPdf.stdout.on 'data', (data) ->
          #console.log("wkhtmltopdf:", data)

        toPdf.stderr.setEncoding('utf8');
        toPdfStderr = ""
        toPdf.stderr.on 'data', (data) ->
          toPdfStderr += data

        toPdf.on 'close', (code) ->
          console.log("wkhtmltopdf exit:", code)
          if code isnt 0
            console.log("wkhtmltopdf error:", toPdfStderr)

        if user.services?.google?.email?
          console.log("Sending Email Link to", user.services.google.email)
          link = Meteor.absoluteUrl("cases/bid/download/#{fileId}?case=#{id}")
          gradesLink = Meteor.absoluteUrl("")
          Email.send 
            from: "grades@sharedrecord.org"
            to: user.services.google.email
            subject: "New BID Generated"
            html: """
              <p>New BUD Generated for #{theCase.name}</p>
              <p><a href="#{link}">Link to BID</a></p>
              <p><a href="#{gradesLink}">Grades</a></p>
            """

      else
        console.log("generatedBid: Could not generate html for bid. id:#{id}")
  
    else
      console.log("generatedBid: Could not get case to generate bid for id:#{id}")

  
  generateMou: (id) ->
    console.log("generateMou", id)
    user = Meteor.user()
    # ensure the user is logged in
    throw new Meteor.Error(401, "Need to be logged in")  unless user

    theCase = Cases.findOne(id)
    
    if theCase?
      
      theCase.today = moment().format('LL')

      theCase.dateOfCustody = moment(theCase.MOU.dataOfCustody).format('LL')
      
      user = Meteor.user()
      google = user?.services?.google
      if user?.profile.name?
        theCase.socialWorkerName = user.profile.name
      else if google?
        theCase.socialWorkerName = google.name or "#{google.given_name} #{google.family_name}"
      else
        theCase.socialWorkerName = "No Name"

      # Generate HTML from handlebars
      html = Handlebars.templates['generatedMou'](theCase)

      if html?
        fileId = moment().format('YYYYMMDD_HHmmss') + '_' + id
        htmlFile = UPLOAD_DIR + 'mous/' + fileId + '.html'
        pdfFile  = UPLOAD_DIR + 'mous/' + fileId + '.pdf'

        fs.writeFileSync(htmlFile, html)
           
        toPdf = child.spawn "wkhtmltopdf", [htmlFile, pdfFile]
        toPdf.stdout.setEncoding('utf8');
        toPdf.stdout.on 'data', (data) ->
          #console.log("wkhtmltopdf:", data)

        toPdf.stderr.setEncoding('utf8');
        toPdfStderr = ""
        toPdf.stderr.on 'data', (data) ->
          toPdfStderr += data

        toPdf.on 'close', (code) ->
          console.log("wkhtmltopdf exit:", code)
          if code isnt 0
            console.log("wkhtmltopdf error:", toPdfStderr)

        if user.services?.google?.email?
          console.log("Sending Email Link to", user.services.google.email)
          link = Meteor.absoluteUrl("cases/mou/download/#{fileId}?case=#{id}")
          gradesLink = Meteor.absoluteUrl("")
          Email.send 
            from: "grades@sharedrecord.org"
            to: user.services.google.email
            subject: "New MOU Generated"
            html: """
              <p>New MOU Generated for #{theCase.name}</p>
              <p><a href="#{link}">Link to MOU</a></p>
              <p><a href="#{gradesLink}">Grades</a></p>
            """


      else
        console.log("generatedMou: Could not generate html for MOU. id:#{id}")
  
    else
      console.log("generatedMou: Could not get case to generate MOU for id:#{id}")


  getBid: (fileId) ->
    user = Meteor.user()
    # ensure the user is logged in
    throw new Meteor.Error(401, "Need to be logged in")  unless user
    
    # TODO: Check ACL
    
    theFile  = UPLOAD_DIR + 'bids/' + fileId + '.html'
    try
      file = fs.readFileSync(theFile, 'utf8')
      if not file
        throw new Meteor.Error(401, "Could not find BID")
      file
    catch e
      console.log("Error getting generated BID", e)
      throw new Meteor.Error(401, "Could not find BID")

  getMou: (fileId) ->
    user = Meteor.user()
    # ensure the user is logged in
    throw new Meteor.Error(401, "Need to be logged in")  unless user

    # TODO: Check ACL
      
    theFile  = UPLOAD_DIR + 'mous/' + fileId + '.html'
    try
      file = fs.readFileSync(theFile, 'utf8')
      if not file
          throw new Meteor.Error(401, "Could not find MOU")
      file
    catch e
      console.log("Error getting generated BID", e)
      throw new Meteor.Error(401, "Could not find BID")
    



