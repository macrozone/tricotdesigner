

	saveChanges =  (element, keys...) ->
		$set = {}
		for key in keys
			$set[key] = element.attrs[key]
		Elements.update {_id: element.getId()}, {$set: $set} 


	BaseEditor = class

		constructor: (@element) ->
			

		save: (keys...)->
			saveChanges @element, keys
			

	
	editors = 
		"Text": class extends BaseEditor
			
			show: ->
				text = prompt "new Text:", @element.attrs.text
				if text? 
					@element.setText text
					@save "text"


	@ElementTools = 
		editors: editors
		saveChanges: saveChanges