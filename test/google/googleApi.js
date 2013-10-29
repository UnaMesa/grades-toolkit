// Generated by CoffeeScript 1.6.3
var CLIENT_ID, CLIENT_SECRET, REDIRECT_URL, SCOPE, auth, googleapis, readline, rl;

googleapis = require("googleapis");

readline = require("readline");

CLIENT_ID = "543454987250@developer.gserviceaccount.com";
//CLIENT_ID = "543454987250.apps.googleusercontent.com";
CLIENT_SECRET = "j8wGc1nCpWMqDX211vlr3lz5";
REDIRECT_URL = "http://localhost:3000/_oauth/google?close";

/*
CLIENT_ID = "695672960977.apps.googleusercontent.com";
CLIENT_SECRET = "-FiR4Hj2eRGzCj_ObdwswG08";
REDIRECT_URL = "http://localhost";
*/

SCOPE = "https://www.googleapis.com/auth/drive.file";

rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

auth = new googleapis.OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL);

googleapis.discover("drive", "v2").execute(function(err, client) {
  var getAccessToken, upload, url;
  url = auth.generateAuthUrl({
    scope: SCOPE
  });
  getAccessToken = function(code) {
    return auth.getToken(code, function(err) {
      if (err) {
        console.log("Error while trying to retrieve access token", err);
        return;
      }
      return upload();
    });
  };
  upload = function() {
    return client.drive.files.insert({
      title: "My Document",
      mimeType: "text/plain"
    }).withMedia("text/plain", "Hello World!").withAuthClient(auth).execute(console.log);
  };
  console.log("Visit the url: ", url);
  return rl.question("Enter the code here:", getAccessToken);
});
