


	Meteor.startup ->
		if Elements.find().count() == 0
			Elements.insert x: 100, y: 100, roomID: "test"

		Meteor.publish "elementsForRoom", (roomID) ->
			Elements.find {roomID: roomID}