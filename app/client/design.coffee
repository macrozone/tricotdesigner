stage = null
userLayer = null
fixedLayer = null


Template.design.rendered = ->

  initStage = _.once =>

    container = @find ".canvasContainer"
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

  initStage()

  clickHandler = (event) ->
    editorClass = ElementTools.editors[@attrs.type]
    if editorClass?
      editor = new editorClass @
      editor.show()
      stage.draw()


  onBoxAdded = (doc) ->
    constructor = Kinetic[doc.type]
    doc.id = doc._id #little translation
    switch doc.type
      when "Image"
        doc.image = new Image()
        doc.image.src = doc.imageURL


    box = new constructor doc

    if doc.fixed
      fixedLayer.add box
    else
      userLayer.add box
    box.off "dragmove"
    box.on "dragmove", _.debounce ->
      ElementTools.saveChanges @, "x", "y"
    , 400

    box.on "click", clickHandler
    box.draw()

  onBoxChanged = (new_doc, old_doc) ->
    boxes = userLayer.find "#" + new_doc._id
    for box in boxes
      box.setAttr key, value for key, value of new_doc

    box.draw()

  onBoxRemoved = (doc) ->
    boxes = userLayer.find "#" + doc._id
    box.destroy() for box in boxes
    

  @data.elements.observe
    changed: onBoxChanged
    added: onBoxAdded
    removed: onBoxRemoved


save = ->
  userLayer.toImage callback: (img)->
    $("body").append $(img)

Template.design.events =
  "click .save": save
  "click .addBox": ->
    Elements.insert type: "Rect", x: 100, y: 100, designID: @design._id, width: 100, height: 100, fill: "red", stroke: "black", strokeWidth: 1, draggable: true

  "click .addText": ->
    textField =
      type: "Text"
      text: "Sample text"
      x: 100
      y: 100
      fill: "red"
      stroke: "black"
      strokeWidth: 1
      fontSize: 128
      fontFamily: "Helvetica Neue"
      textFill: "#000"
      align: "center"
      verticalAlign: "middle"
      designID: @design._id
      draggable: true

    Elements.insert textField

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

