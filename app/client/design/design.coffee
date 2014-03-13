stage = null
userLayer = null
fixedLayer = null
MAX_IMAGE_WIDTH = 300
FILEPICKER_KEY = "AZn7jUYrTzGpTqACG1LLFz"

createElement = (doc, callback) ->
  console.log "create", doc
  doc.id = doc._id #little translation
  createIt =  ->
    constructor = Kinetic[doc.type]
    element = new constructor doc


  # some preparations
  switch doc.type
    when "Image"
      doc.name = "image"
      doc.image = new Image()
      doc.image.src = doc.imageURL
      doc.image.onload = ->

        width = doc.image.width
        height = doc.image.height
        factor = width / height
        # limit
        width = Math.min MAX_IMAGE_WIDTH, width
        height = width / factor

        unless doc.width?
          doc.width = width
        unless doc.height?
          doc.height = height

        doc.draggable = false
        element = createIt()
        unless doc.fixed

          element.setX 0
          element.setY 0
          resizable = new Kinetic.Resizable
            id: doc.id
            image : element
            layer : userLayer
            stage : stage
            x: doc.x
            y: doc.y

          resizable.reSize doc.width, doc.height
          resizable.group.on "dragend", ->
            ElementTools.saveChanges element, x: @getX(), y: @getY()
        else
          fixedLayer.add element
        callback element
    else
      element = createIt()
      if doc.fixed
        fixedLayer.add element
      else
        userLayer.add element
      callback element




initTemplate = (template) ->

  filepicker.setKey FILEPICKER_KEY
  container = template.find ".canvasContainer"
  $(container).css "transform-origin", "0 0"
  $(container).width Settings.width
  $(container).height Settings.height
  $(container).css "transform", "scale(#{1/Settings.scaleFactor})"
  stage = new Kinetic.Stage
    container: container
    width: Settings.width * Settings.scaleFactor
    height: Settings.height * Settings.scaleFactor
  userLayer = new Kinetic.Layer
  fixedLayer = new Kinetic.Layer
  stage.add fixedLayer
  stage.add userLayer


initElements = (elements)->
  clickHandler = (event) ->
    editorClass = ElementTools.editors[@attrs.type]
    if editorClass?
      editor = new editorClass @
      editor.show()
      stage.draw()


  onElementAdded = (doc) ->

    createElement doc, (element) ->
      element.on "dragend", ->
        ElementTools.saveChanges @


      element.on "click", clickHandler
      element.draw()

  onElementChanged = (new_doc, old_doc) ->
    elements = userLayer.find "#" + new_doc._id
    for element in elements
      element.setAttr key, value for key, value of new_doc
      stage.draw()



  onElementRemoved = (doc) ->
    elements = userLayer.find "#" + doc._id
    element.destroy() for element in elements


  elements.observe
    changed: onElementChanged
    added: onElementAdded
    removed: onElementRemoved

initialized = false
Template.design.rendered = ->
  unless initialized
    initialized = true
    initTemplate @
    initElements @.data.elements







Template.oneElement.events =
  "click .btn-remove": ->
    Elements.remove _id: @_id


Router.map ->
  @route 'design',
    path: "/design/:_id",
    before: ->
      @subscribe('allDesigns').wait()
      @subscribe('elementsForDesign', @params._id).wait()
    data: ->
      design: Designs.findOne {_id: @params._id}
      elements: Elements.find {designID: @params._id}
    action: ->
      if @ready()
        @render()

