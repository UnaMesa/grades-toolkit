
/*
    See: https://github.com/jpillora/node-edit-google-spreadsheet

*/

Package.describe({
  summary: "A simple API for reading and writing to Google Spreadsheets"
});

Npm.depends({"edit-google-spreadsheet": '0.2.2'});

Package.on_use(function (api) {
    api.use(['coffeescript'], 'server');
  
    api.add_files('google-spreadsheet.coffee', 'server');
    
    if(api.export)
        api.export('GoogleSpreadsheet');
});