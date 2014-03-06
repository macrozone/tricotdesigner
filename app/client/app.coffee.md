




	Template.room.rendered = ->
		
		stage = new Kinetic.Stage 
			container: @find ".canvasContainer"
			width: 600
			height: 300

		layer = new Kinetic.Layer
		stage.add layer

		onBoxAdded = (doc) ->
			box = new Kinetic.Rect id: doc._id, x: doc.x, y: doc.y, width: 50, height: 50, fill:"red", stroke:"black", strokeWidth: 1, draggable: true
			layer.add box
			box.on "dragmove", _.throttle ->
				query = {_id: @getId()}
				data = {$set: {x: @attrs.x, y: @attrs.y}}
				Entities.update query, data
			,300

			box.on "click", ->
				Entities.remove {_id: @getId()}
			layer.draw()
		
		onBoxChanged = (new_doc, old_doc) ->
			boxes = layer.find "#"+new_doc._id
			_.each boxes, (box) ->
				box.position new_doc
			layer.draw()
	
		onBoxRemoved = (doc) ->
			boxes = layer.find "#"+doc._id
			_.each boxes, (box) ->
				box.destroy()
			layer.draw()

		@data.entities.observe 
			changed: onBoxChanged
			added: onBoxAdded
			removed: onBoxRemoved 

			
		
	Template.room.events = 
		"click .addBox": ->
			Entities.insert x: 100, y: 100, roomID: @roomID

	

	
	Router.map ->
		@route 'room', 
			path: "/room/:_id", 
			before: ->
      			@subscribe('entitiesForRoom', @params._id).wait()
			data: ->
				roomID: @params._id, entities: Entities.find {roomID: @params._id}
			
	