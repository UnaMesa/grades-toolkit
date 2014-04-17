#
#  Generate MOUs and BIDs
#

fs     = Npm.require('fs')
child  = Npm.require('child_process')

UPLOAD_DIR = '/var/spool/grades/'


documentsUsedForBid = (rec) ->
    vals = []
    for val in BID.documentsUsed
         data =
             key: val
         if rec.BID?.documentsUsed and val in rec.BID.documentsUsed
             data.checked = "check-"
         vals.push(data)
    vals


considerations = (rec) ->
    considerations = []
    index = 0
    for consideration in BID.considerations
        data = _.clone(consideration)
        index++
        data.index = index
        if data.helpBlock
            data.helpText = "<ul>"
            for help in data.helpBlock
                data.helpText +=  '<li>' + help + '</li>';
            data.helpText += "</ul>"
        if rec.BID?.considerations
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



Meteor.methods
  
  generateBid: (id) ->
    console.log("generateBid", id)

    theCase = Cases.findOne(id)

    if theCase?
      theCase.bidDate = moment().format('lll')

      theCase.documentsUsedForBid = documentsUsedForBid(theCase)
      theCase.considerations = considerations(theCase)
      theCase.stayAtCurrentSchool = stayAtCurrentSchool(theCase)
      theCase.moveToNewSchool = moveToNewSchool(theCase)
      theCase.teamDisagrees = teamDisagrees(theCase)
      theCase.currentSchool = currentSchool(theCase)
      theCase.currentSUSD = currentSUSD(theCase)
      theCase.newSchool = newSchool(theCase)
      theCase.newSUSD = newSUSD(theCase)

      html = Handlebars.templates['generatedBid'](theCase)

      if html?
        htmlFile = UPLOAD_DIR + 'bids/' + moment().format('YYYY-MM-DD-HH-mm-ss') + '_' + id + '.html'
        pdfFile  = UPLOAD_DIR + 'bids/' + moment().format('YYYY-MM-DD-HH-mm-ss') + '_' + id + '.pdf'

        fs.writeFile htmlFile, html, (err) ->
          if err
            console.log("Error writing BID #{htmlFile}", err)
          else 
            toPdf = child.spawn "wkhtmltopdf", [htmlFile, pdfFile]
            toPdf.stdout.setEncoding('utf8');
            toPdf.stdout.on 'data', (data) ->
              console.log("wkhtmltopdf:", data)

            toPdf.stderr.setEncoding('utf8');
            toPdfStderr = ""
            toPdf.stderr.on 'data', (data) ->
              toPdfStderr += data

            toPdf.on 'close', (code) ->
              console.log("wkhtmltopdf exit:", code)
              if code isnt 0
                console.log("wkhtmltopdf error:", toPdfStderr)

      else
        console.log("generatedBid: Could not generate html for bid. id:#{id}")
  
    else
      console.log("generatedBid: Could not get case to generate bid for id:#{id}")



  generateMou: (id) ->
    console.log("generateMou", id)

    theCase = Cases.findOne(id)
    
    if theCase?
      
      theCase.today = moment().format('LL')

      theCase.dateOfCustody = moment(theCase.MOU.dataOfCustody).format('LL')
      html = Handlebars.templates['generatedMou'](theCase)

      if html?
        htmlFile = UPLOAD_DIR + 'mous/' + moment().format('YYYY-MM-DD-HH-mm-ss') + '_' + id + '.html'
        pdfFile  = UPLOAD_DIR + 'mous/' + moment().format('YYYY-MM-DD-HH-mm-ss') + '_' + id + '.pdf'

        fs.writeFile htmlFile, html, (err) ->
          if err
            console.log("Error writing MOU #{htmlFile}", err)
          else 
            toPdf = child.spawn "wkhtmltopdf", [htmlFile, pdfFile]
            toPdf.stdout.setEncoding('utf8');
            toPdf.stdout.on 'data', (data) ->
              console.log("wkhtmltopdf:", data)

            toPdf.stderr.setEncoding('utf8');
            toPdfStderr = ""
            toPdf.stderr.on 'data', (data) ->
              toPdfStderr += data

            toPdf.on 'close', (code) ->
              console.log("wkhtmltopdf exit:", code)
              if code isnt 0
                console.log("wkhtmltopdf error:", toPdfStderr)

      else
        console.log("generatedMou: Could not generate html for MOU. id:#{id}")
  
    else
      console.log("generatedMou: Could not get case to generate MOU for id:#{id}")

