Router.configure layoutTemplate: 'layout'

Router.map ->
  @route 'home',
    path: "/"
    before: ->
      @subscribe('allDesigns').wait()
    data: ->
      designs: Designs.find()

addDefaultElements = (designID) ->
  element =
    type: "Image"
    width: 704 * Settings.scaleFactor
    height: 370 * Settings.scaleFactor
    x: 0
    y: 0
    imageURL: "/t-shirt-template.jpg"
    designID: designID
    draggable: false
    fixed: true
  Elements.insert element

createDesign = ->
  designID = Designs.insert {}
  addDefaultElements designID
  Router.go "design", _id: designID

Template.home.events =
  "click .btn-create-design": createDesign


