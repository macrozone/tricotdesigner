


initTemplate = (template) ->
	container = template.find ".canvasContainer"
	settings = 
		container: container
		interactive: true
		scaleFactor: 1
		width: Meteor.settings.public.canvas.width
		height: Meteor.settings.public.canvas.height
	filepicker.setKey Meteor.settings.public.filepicker
		
	
	$(container).css "transform-origin", "0 0"
	$(container).width settings.width
	$(container).height settings.height
	$(container).css "transform", "scale(#{1/settings.scaleFactor})"

	

	designer = new Designer settings
	designer.init template.data.elements



Template.design.rendered = ->
	initTemplate @


Template.oneElement.events =
	"click .btn-remove": ->
		Elements.remove _id: @_id


Router.map ->
	@route 'design',
		path: "/design/:_id",
		onBeforeAction: ->

			@subscribe('allDesigns').wait()
			@subscribe('elementsForDesign', @params._id).wait()
		data: ->
			design: Designs.findOne {_id: @params._id}
			elements: Elements.find {designID: @params._id}
		action: ->
			if @ready() then @render()
