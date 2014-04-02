Template.design.events
	"click .save": (event, template)->
		Session.set "designSaved"
		console.log "save"
		console.log template.find ".saveModal"
		$(template.find ".saveModal").modal()
		Meteor.call "save", @design._id, (error, savedImage) ->
			Session.set "designSaved", savedImage

Template.saveModal.image = ->
	Session.get "designSaved"
