Future = Npm.require('fibers/future');
filepicker = new Filepicker Meteor.settings.public.filepicker
Facts.setUserIdFilter -> true
Meteor.startup ->
	if Elements.find().count() == 0
		Elements.insert x: 100, y: 100, designID: "test"

	Meteor.publish "allDesigns", ->
		Designs.find()
	Meteor.publish "elementsForDesign", (designID) ->
		Elements.find designID: designID



	

Meteor.methods
	"save": (designID) ->

		future = new Future()
		@unblock()

		settings =
			width: Meteor.settings.public.canvas.width
			height: Meteor.settings.public.canvas.height
			scaleFactor: Meteor.settings.public.canvas.saveScaleFactor

		elements = Elements.find designID: designID
		fs = Npm.require('fs')
		path = Npm.require('path')
		designer = new Designer settings
		designer.init elements, Meteor.bindEnvironment ->
			designer.toDataURL Meteor.bindEnvironment (data) ->
				future['return'] data
		
		future.wait()
