


	init = ->

		stage = null
		layer = null

		initStage = _.once =>
			stage = new Kinetic.Stage 
				container: @find ".canvasContainer"
				width: 600
				height: 300
			layer = new Kinetic.Layer
			stage.add layer

		initStage()

		clickHandler = (event) ->
			switch @attrs.type
				when 'Text'
					@setText prompt "new Text:"
					Entities.update {_id: @getId()}, {$set: {text: @attrs.text}}

			layer.draw()


		onBoxAdded = (doc) ->
			constructor = Kinetic[doc.type]
			doc.id = doc._id #little translation
			box = new constructor doc
			
			#box = new Kinetic.Rect id: doc._id, x: doc.x, y: doc.y, width: 50, height: 50, fill:"red", stroke:"black", strokeWidth: 1, draggable: true
			layer.add box
			box.on "dragmove", _.throttle ->
				Entities.update {_id: @getId()}, {$set: {x: @attrs.x, y: @attrs.y}}
			,300

			box.on "click", clickHandler
			layer.draw()
		
		onBoxChanged = (new_doc, old_doc) ->
			boxes = layer.find "#"+new_doc._id
			for box in boxes
				box.setAttr key, value for key, value of new_doc

			
			layer.draw()
	
		onBoxRemoved = (doc) ->
			boxes = layer.find "#"+doc._id
			box.destroy() for box in boxes	
			layer.draw()

		@data.entities.observe 
			changed: onBoxChanged
			added: onBoxAdded
			removed: onBoxRemoved 


	Template.room.rendered = ->
		 init.call this

	Template.room.events = 
		"click .addBox": ->
			Entities.insert type: "Rect", x: 100, y: 100, roomID: @roomID, width: 50, height: 50, fill:"red", stroke:"black", strokeWidth: 1, draggable: true
		"click .addText": ->
			textField = 
				type: "Text"
				text: "Sample text"
				x: 10
				y: 10
				fill: "green"
				fontSize: 14
				fontFamily: "Helvetica Neue"
				textFill: "#000"
				align: "center"
				verticalAlign: "middle"
				roomID: @roomID
				draggable: true
		
			Entities.insert textField
					
	
	
	Router.map ->
		@route 'room', 
			path: "/room/:_id", 
			before: ->
      			@subscribe('entitiesForRoom', @params._id).wait()
			data: ->
				roomID: @params._id, entities: Entities.find {roomID: @params._id}
			
	