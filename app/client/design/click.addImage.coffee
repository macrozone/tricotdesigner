Template.design.events
  "click .addImage": ->
    filepicker.pick (inkBlob) =>
      element =
        type: "Image"
        imageURL: inkBlob.url
        designID: @design._id
        x: 100
        y: 100
      Elements.insert element


