###

update = (activeAnchor) ->
  group = activeAnchor.getParent()
  topLeft = group.find(".topLeft")[0]
  topRight = group.find(".topRight")[0]
  bottomRight = group.find(".bottomRight")[0]
  bottomLeft = group.find(".bottomLeft")[0]
  image = group.find(".image")[0]
  anchorX = activeAnchor.x()
  anchorY = activeAnchor.y()

  # update anchor positions
  switch activeAnchor.name()
    when "topLeft"
      topRight.y anchorY
      bottomLeft.x anchorX
    when "topRight"
      topLeft.y anchorY
      bottomRight.x anchorX
    when "bottomRight"
      bottomLeft.y anchorY
      topRight.x anchorX
    when "bottomLeft"
      bottomRight.y anchorY
      topLeft.x anchorX
  image.setPosition topLeft.getPosition()
  width = topRight.x() - topLeft.x()
  height = bottomLeft.y() - topLeft.y()
  if width and height
    image.setSize
      width: width
      height: height

  return
addAnchor = (group, x, y, name) ->
  stage = group.getStage()
  layer = group.getLayer()
  anchor = new Kinetic.Circle(
    x: x
    y: y
    stroke: "#666"
    fill: "#ddd"
    strokeWidth: 2
    radius: 8
    name: name
    draggable: true
    dragOnTop: false
  )
  anchor.on "dragmove", ->
    update this
    layer.draw()
    return

  anchor.on "mousedown touchstart", ->
    group.setDraggable false
    @moveToTop()
    return

  anchor.on "dragend", ->
    group.setDraggable true
    layer.draw()
    return


  # add hover styling
  anchor.on "mouseover", ->
    layer = @getLayer()
    document.body.style.cursor = "pointer"
    @setStrokeWidth 4
    layer.draw()
    return

  anchor.on "mouseout", ->
    layer = @getLayer()
    document.body.style.cursor = "default"
    @strokeWidth 2
    layer.draw()
    return

  group.add anchor
  return
loadImages = (sources, callback) ->
  images = {}
  loadedImages = 0
  numImages = 0
  for src of sources
    numImages++
  for src of sources
    images[src] = new Image()
    images[src].onload = ->
      callback images  if ++loadedImages >= numImages
      return

    images[src].src = sources[src]
  return
initStage = (images) ->
  stage = new Kinetic.Stage(
    container: "container"
    width: 578
    height: 400
  )
  darthVaderGroup = new Kinetic.Group(
    x: 270
    y: 100
    draggable: true
  )
  yodaGroup = new Kinetic.Group(
    x: 100
    y: 110
    draggable: true
  )
  layer = new Kinetic.Layer()

  #
  #         * go ahead and add the groups
  #         * to the layer and the layer to the
  #         * stage so that the groups have knowledge
  #         * of its layer and stage
  #         
  layer.add darthVaderGroup
  layer.add yodaGroup
  stage.add layer

  # darth vader
  darthVaderImg = new Kinetic.Image(
    x: 0
    y: 0
    image: images.darthVader
    width: 200
    height: 138
    name: "image"
  )
  darthVaderGroup.add darthVaderImg
  addAnchor darthVaderGroup, 0, 0, "topLeft"
  addAnchor darthVaderGroup, 200, 0, "topRight"
  addAnchor darthVaderGroup, 200, 138, "bottomRight"
  addAnchor darthVaderGroup, 0, 138, "bottomLeft"
  darthVaderGroup.on "dragstart", ->
    @moveToTop()
    return


  # yoda
  yodaImg = new Kinetic.Image(
    x: 0
    y: 0
    image: images.yoda
    width: 93
    height: 104
    name: "image"
  )
  yodaGroup.add yodaImg
  addAnchor yodaGroup, 0, 0, "topLeft"
  addAnchor yodaGroup, 93, 0, "topRight"
  addAnchor yodaGroup, 93, 104, "bottomRight"
  addAnchor yodaGroup, 0, 104, "bottomLeft"
  yodaGroup.on "dragstart", ->
    @moveToTop()
    return

  stage.draw()
  return
sources =
  darthVader: "http://www.html5canvastutorials.com/demos/assets/darth-vader.jpg"
  yoda: "http://www.html5canvastutorials.com/demos/assets/yoda.jpg"

loadImages sources, initStage


###