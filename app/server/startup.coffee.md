


	Meteor.startup ->
		if Entities.find().count() == 0
			Entities.insert x: 100, y: 100, roomID: "test"

		Meteor.publish "entitiesForRoom", (roomID) ->
			Entities.find {roomID: roomID}