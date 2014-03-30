MAX_IMAGE_WIDTH = 300

if Meteor.isServer
	request = Npm.require('request').defaults({ encoding: null })

@Designer = class
	constructor: (@settings) ->
		initOptions =
			width: @settings.width*@settings.scaleFactor
			height: @settings.height*@settings.scaleFactor
			scaleX: @settings.scaleFactor
			scaleY: @settings.scaleFactor
			container: @settings.container

		@settings.interactive = false if Meteor.isServer
		@stage = new Kinetic.Stage initOptions
		@userLayer = new Kinetic.Layer
		@fixedLayer = new Kinetic.Layer
		@stage.add @fixedLayer
		@stage.add @userLayer

	init: (elements, readyCallback)->
		if Meteor.isServer
			@initServer elements,readyCallback
		else
			@initClient elements,readyCallback

	

	

	initServer: (elements,readyCallback) ->
		elementsTotal = elements.count()
		elementsReady = 0
		elements.forEach (doc) =>
			onSuccess = (element) =>
				element.draw()
				elementsReady++
				console.log elementsReady, elementsTotal
				if elementsTotal == elementsReady
					if _.isFunction readyCallback then readyCallback()
			onError = (error) =>
				elementsReady++
				console.log elementsReady, elementsTotal
				if elementsTotal == elementsReady
					if _.isFunction readyCallback then readyCallback()
			@createKineticElement doc, onSuccess, onError


	initClient: (elements, readyCallback) ->

		onElementAdded = (doc) =>
			@createKineticElement doc, (element) =>
				if @settings.interactive
					@addElementHandles element
				element.draw()

		onElementChanged = (new_doc, old_doc) =>
			elements = @userLayer.find "#" + new_doc._id
			for element in elements
				element.setAttr key, value for key, value of new_doc
				@stage.draw()

		onElementRemoved = (doc) =>
			elements = @userLayer.find "#" + doc._id
			element.destroy() for element in elements
			@stage.draw()

		elements.observe
			changed: onElementChanged
			added: onElementAdded
			removed: onElementRemoved
		if _.isFunction readyCallback then readyCallback()

	createDomImage: ->
		if Kinetic? and Kinetic.window?
			new Kinetic.window.Image()
		else
			new Image()

	toDataURL: (callback) ->
		@stage.toDataURL callback: callback

	addElementHandles: (element) ->
		element.on "dragmove", ->
			ElementTools.saveChanges @
		element.on "click", (event) =>
			@onElementClick element, event

	onElementClick: (element, event) ->
		editorClass = ElementTools.editors[element.attrs.type]
		if editorClass?
			editor = new editorClass element
			editor.show()


	createKineticElement: (doc, callback, errorCallback) ->
		doc.id = doc._id #little translation
		createIt = =>
			constructor = Kinetic[doc.type]
			element = new constructor doc
		initDefaultElement = =>
			element = createIt()
			if doc.fixed
				@fixedLayer.add element
			else
				@userLayer.add element
			callback element
		initImage = =>
			doc.draggable =  false
			doc.name = "image"
			doc.image = @createDomImage()
			doc.image.onload = =>
				console.log "image loaded #{doc.imageURL}"
				width = doc.image.width
				height = doc.image.height
				factor = width / height

				# limit
				width = Math.min MAX_IMAGE_WIDTH, width
				height = width / factor

				doc.width = width unless doc.width?
				doc.height = height unless doc.height?
					
				element = createIt()

				unless doc.fixed
					if @settings.interactive
						@wrapImageInResizer element
					else
						@userLayer.add element
				else
					@fixedLayer.add element
				callback element
			
			doc.image.onerror = (error) ->
				console.log error
				if _.isFunction errorCallback 
					errorCallback error

			if Meteor.isServer
				request doc.imageURL, (err, res, data) -> doc.image.src = data
			else
				doc.image.src = doc.imageURL

		# some preparations
		switch doc.type
			when "Image" then initImage()
			else initDefaultElement()
				

	wrapImageInResizer: (element) ->
		x = element.getX()
		y = element.getY()
		element.setX 0
		element.setY 0
		element.draggable = false
		resizable = new Kinetic.Resizable
			id: element.getId()
			image : element
			layer : @userLayer
			stage : @stage
			x: x
			y: y

		resizable.init element.getWidth(), element.getHeight()
		resizable.group.on "dragmove", ->
			ElementTools.saveChanges element, x: @getX(), y: @getY()


