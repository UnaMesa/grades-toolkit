Package.describe({
  summary: "Meteor Wrapper for JSEncrypt, a RSA javascript encryption library"
});

Package.on_use(function (api) {
  
  api.add_files('lib/jsencrypt.js', 'client');

  if (api.export)
        api.export('JSEncrypt');
});