Package.describe({
    summary: "Bootstrap Switch, packaged for Meteor using less."
});

Package.on_use(function (api, where) {
    api.use('jquery', 'client');
    api.use('less','client');
    api.add_files('lib/js/bootstrap-switch.js', 'client');
});