
Meteor.startup ->
  if Elements.find().count() == 0
    Elements.insert x: 100, y: 100, designID: "test"

  Meteor.publish "allDesigns", ->
    Designs.find()
  Meteor.publish "elementsForDesign", (designID) ->
    Elements.find designID: designID



  settings =
    width: 800
    height: 400
    scaleFactor: 1

  ###
  elements = Elements.find designID: "kzh3tg9vGMSPFnsbs"
  designer = new Designer elements, settings
  designer.init()

  ###