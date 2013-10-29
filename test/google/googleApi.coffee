googleapis = require("googleapis")
readline = require("readline")
      
CLIENT_ID = "695672960977@apps.googleusercontent.com"
CLIENT_SECRET = "-FiR4Hj2eRGzCj_ObdwswG08"
REDIRECT_URL = "http://localhost"

SCOPE = "https://www.googleapis.com/auth/drive.file"

rl = readline.createInterface
  input: process.stdin
  output: process.stdout


@auth = new googleapis.OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL)

googleapis.discover("drive", "v2").execute (err, client) ->
  url = auth.generateAuthUrl(scope: SCOPE)
  getAccessToken = (code) ->
    console.log("Code", code)
    auth.getToken code, (err) ->
      if err
        console.log "Error while trying to retrieve access token", err
        return
      upload()


  upload = (auth) ->

    client.drive.files.insert(
      title: "My Document"
      mimeType: "text/plain"
    ).withMedia("text/plain", "Hello World!").withAuthClient(auth).execute console.log

  console.log "Visit the url: ", url
  rl.question "Enter the code here:", getAccessToken

