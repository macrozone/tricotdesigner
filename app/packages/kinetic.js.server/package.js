Npm.depends({
    'canvas':"1.1.3",
    'KineticJS': '5.0.2' // Where x.x.x is the version, e.g. 0.3.2
});

Package.on_use(function (api) {

    api.add_files('kinetic.js', 'server'); // Or 'client', or ['server', 'client']
    api.export(['Kinetic'], 'server');
});