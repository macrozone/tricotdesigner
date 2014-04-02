console.log Meteor.settings

@Designs = new Meteor.Collection "designs"
@Elements = new Meteor.Collection "elements"

@SavedDesignImages = new FS.Collection 'savedDesignImages',
	stores: [new FS.Store.FileSystem 'savedDesignImages', path: "~/saved_design_images"]


