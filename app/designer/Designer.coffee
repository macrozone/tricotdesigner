MAX_IMAGE_WIDTH = 300

@Designer = class
  constructor: (@elements, @settings) ->
    initOptions =
      width: @settings.width * @settings.scaleFactor
      height: @settings.height * @settings.scaleFactor
    if @settings.container?
      initOptions.container = @settings.container

    @stage = new Kinetic.Stage initOptions


    @userLayer = new Kinetic.Layer
    @fixedLayer = new Kinetic.Layer
    @stage.add @fixedLayer
    @stage.add @userLayer

  init: ->

    onElementAdded = (doc) =>
      @createKineticElement doc, (element) =>
        if @settings.interactive
          @addElementHandles element
        element.draw()

    onElementChanged = (new_doc, old_doc) =>
      elements = @userLayer.find "#" + new_doc._id
      for element in elements
        element.setAttr key, value for key, value of new_doc
        @stage.draw()

    onElementRemoved = (doc) =>
      elements = @userLayer.find "#" + doc._id
      element.destroy() for element in elements
      @stage.draw()

    @elements.observe
      changed: onElementChanged
      added: onElementAdded
      removed: onElementRemoved

  addElementHandles: (element) ->
    element.on "dragend", ->
      ElementTools.saveChanges @
    element.on "click", (event) =>
      @onElementClick element, event

  onElementClick: (element, event) ->
    editorClass = ElementTools.editors[element.attrs.type]
    if editorClass?
      editor = new editorClass element
      editor.show()

  createKineticElement: (doc, callback) ->
    doc.id = doc._id #little translation
    createIt = ->
      constructor = Kinetic[doc.type]
      element = new constructor doc

    # some preparations
    switch doc.type
      when "Image"
        if @settings.interactive
          doc.draggable =  false

        doc.name = "image"
        doc.image = new Image()
        doc.image.src = doc.imageURL
        doc.image.onload = =>

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

          element = createIt()

          unless doc.fixed
            if @settings.interactive
              @wrapImageInResizer element
            else
              @userLayer.add element
          else
            @fixedLayer.add element

          callback element
      else
        element = createIt()
        if doc.fixed
          @fixedLayer.add element
        else
          @userLayer.add element
        callback element

  wrapImageInResizer: (element) ->
    x = element.getX()
    y = element.getY()
    element.setX 0
    element.setY 0
    element.draggable = false
    resizable = new Kinetic.Resizable
      id: element.getId()
      image : element
      layer : @userLayer
      stage : @stage
      x: x
      y: y

    resizable.init element.getWidth(), element.getHeight()
    resizable.group.on "dragmove", ->
      ElementTools.saveChanges element, x: @getX(), y: @getY()


