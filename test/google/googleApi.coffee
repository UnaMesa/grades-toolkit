googleapis = require("googleapis")
readline = require("readline")

CLIENT_ID = "543454987250.apps.googleusercontent.com"
CLIENT_SECRET = "j8wGc1nCpWMqDX211vlr3lz5"
REDIRECT_URL = "http://localhost:3000/_oauth/google?close"

SCOPE = "https://www.googleapis.com/auth/drive.file"

rl = readline.createInterface
  input: process.stdin
  output: process.stdout


auth = new googleapis.OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL)

googleapis.discover("drive", "v2").execute (err, client) ->
  url = auth.generateAuthUrl(scope: SCOPE)
  getAccessToken = (code) ->
    auth.getToken code, (err) ->
      if err
        console.log "Error while trying to retrieve access token", err
        return
      upload()


  upload = ->
    client.drive.files.insert(
      title: "My Document"
      mimeType: "text/plain"
    ).withMedia("text/plain", "Hello World!").withAuthClient(auth).execute console.log

  console.log "Visit the url: ", url
  rl.question "Enter the code here:", getAccessToken

