Package.describe({
  summary: "Wrapper for Google APIs Client Library for Node"
});

Npm.depends({googleapis: '0.7.0'});

Package.on_use(function (api) {
    api.add_files('google.js', 'server');
    if(api.export)
        api.export('GoogleApi');
});