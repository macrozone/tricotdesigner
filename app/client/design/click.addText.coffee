Template.design.events
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