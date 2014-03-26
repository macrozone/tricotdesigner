
saveList = ["imageURL", "x","y", "width", "height", "text"]

saveChanges = _.debounce (element, overrideValues) ->
  $set = {}
  for key in saveList
    if overrideValues?[key]?
      value = overrideValues?[key]
    else
      value = element.attrs[key]
    if value?
      $set[key] = value
  console.log $set
  Elements.update {_id: element.getId()}, {$set: $set}
, 0

BaseEditor = class

  constructor: (@element) ->


  save:->
    saveChanges @element


editors =
  "Text": class extends BaseEditor

    show: ->
      text = prompt "new Text:", @element.attrs.text
      if text?
        @element.setText text
        @save()



@ElementTools =
  editors: editors
  saveChanges: saveChanges