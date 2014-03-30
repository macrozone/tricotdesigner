Facts.setUserIdFilter -> true
Meteor.startup ->
	if Elements.find().count() == 0
		Elements.insert x: 100, y: 100, designID: "test"

	Meteor.publish "allDesigns", ->
		Designs.find()
	Meteor.publish "elementsForDesign", (designID) ->
		Elements.find designID: designID




	

Meteor.methods
	"renderImage": (designID) ->

		settings =
		width: 800
		height: 400
		scaleFactor: 8
	
		elements = Elements.find designID: designID
		fs = Npm.require('fs')
		path = Npm.require('path')
		designer = new Designer settings
		designer.init elements, ->
			designer.toDataURL (data)->
				base64Data = data.replace(/^data:image\/png;base64,/, "")
				file = path.resolve "./design_#{designID}.png"
				fs.writeFile file, base64Data, "base64", (err) ->
					console.log err

				
	
		