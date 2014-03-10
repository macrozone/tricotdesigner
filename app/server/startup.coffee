
Meteor.startup ->
  if Elements.find().count() == 0
    Elements.insert x: 100, y: 100, designID: "test"

  Meteor.publish "allDesigns", ->
    Designs.find()
  Meteor.publish "elementsForDesign", (designID) ->
    Elements.find designID: designID