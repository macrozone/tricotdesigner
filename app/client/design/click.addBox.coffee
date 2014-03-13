Template.design.events
  "click .addBox": ->
    Elements.insert type: "Rect", x: 100, y: 100, designID: @design._id, width: 100, height: 100, fill: "red", stroke: "black", strokeWidth: 1, draggable: true
