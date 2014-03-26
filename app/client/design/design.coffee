

FILEPICKER_KEY = "AZn7jUYrTzGpTqACG1LLFz"


initTemplate = (template) ->

  filepicker.setKey FILEPICKER_KEY
  container = template.find ".canvasContainer"
  $(container).css "transform-origin", "0 0"
  $(container).width Settings.width
  $(container).height Settings.height
  $(container).css "transform", "scale(#{1/Settings.scaleFactor})"
  settings = Settings
  settings.container = container
  settings.interactive = true

  designer = new Designer template.data.elements, settings
  designer.init()


initialized = false
Template.design.rendered = ->
  unless initialized
    initialized = true
    initTemplate @


Template.oneElement.events =
  "click .btn-remove": ->
    Elements.remove _id: @_id


Router.map ->
  @route 'design',
    path: "/design/:_id",
    before: ->
      initialized = false
      @subscribe('allDesigns').wait()
      @subscribe('elementsForDesign', @params._id).wait()
    data: ->
      design: Designs.findOne {_id: @params._id}
      elements: Elements.find {designID: @params._id}
    action: ->
      if @ready() then @render()
