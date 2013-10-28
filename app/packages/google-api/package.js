Package.describe({
  summary: "Wrapper for Google APIs Client Library for Node"
});
Npm.depends({googleapis: '0.4.5'});

Package.on_use(function (api) {
    api.use(['coffeescript'], 'server');
  
    api.add_files('google.coffee', 'server');
    if(api.export)
        api.export('GoogleApi');
});