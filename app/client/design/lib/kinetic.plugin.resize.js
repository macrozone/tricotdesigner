Kinetic.Resizable = function(options) {
  //Initalize a Group
	var image = options.image;
	var layer = options.layer;
	var stage = options.stage;
    var id = options.id;
	var yodaGroup = new Kinetic.Group({
          id: id,
          x: options.x,
          y: options.y,
          draggable: true
        });
    layer.add(yodaGroup);
    yodaGroup.add(image);
    stage.add(layer);
    //Attach anchors
    this.reSize = function(width,height){
        addAnchor(yodaGroup, 0, 0, "topLeft");
        addAnchor(yodaGroup, width, 0, "topRight");
        addAnchor(yodaGroup, width, height, "bottomRight");
        addAnchor(yodaGroup, 0, height, "bottomLeft");
        yodaGroup.on("dragstart", function() {
          this.moveToTop();
        });
        stage.draw();
    }

    var originalSetAttr = yodaGroup._setAttr;
    that = this;
    yodaGroup._setAttr = function(key, value)
    {
        switch(key)
        {
            case 'width':
                updateWidth.call(that, value);
                break
            case 'height':
                updateHeight.call(that, value);
                break;
            default:
                originalSetAttr.call(yodaGroup, key,value);
                break;
        }
    }

    this.group = yodaGroup;
    this.image = image;
  };


   function updateWidth(width)
   {
       this.image.setWidth(width);
       var topRight = this.group.get('.topRight')[0];
       var bottomRight = this.group.get('.bottomRight')[0];

       topRight.setX(width);
       bottomRight.setX(width);
   }

function updateHeight(height)
{
    this.image.setHeight(height);
    var bottomRight = this.group.get('.bottomRight')[0];
    var bottomLeft = this.group.get('.bottomLeft')[0];
    bottomLeft.setY(height);
    bottomRight.setY(height);

}

  function update(activeAnchor) {

        var group = activeAnchor.getParent();
        var topLeft = group.get('.topLeft')[0]; //you can change the alignment ot the anchors here
        var topRight = group.get('.topRight')[0];
        var bottomRight = group.get('.bottomRight')[0];
        var bottomLeft = group.get('.bottomLeft')[0];
        var image = group.get('.image')[0];

        var anchorX = activeAnchor.getX();
        var anchorY = activeAnchor.getY();

        // update anchor positions
        switch (activeAnchor.getName()) {
          case 'topLeft':

            group.setY(group.getY()+anchorY);
            group.setX(group.getX()+anchorX);
              bottomRight.setX(bottomRight.getX()-anchorX);
              topRight.setX(topRight.getX()-anchorX);
              bottomLeft.setY(bottomLeft.getY()-anchorY);
              bottomRight.setY(bottomRight.getY()-anchorY);
            break;
          case 'topRight':
            group.setY(group.getY()+anchorY);

            bottomRight.setX(anchorX);
            bottomLeft.setY(bottomLeft.getY()-anchorY);
            bottomRight.setY(bottomRight.getY()-anchorY);
            break;
          case 'bottomRight':
            bottomLeft.setY(anchorY);
            topRight.setX(anchorX); 
            break;
          case 'bottomLeft':
            bottomRight.setY(anchorY);
            group.setX(group.getX()+anchorX);

            bottomRight.setX(bottomRight.getX()-anchorX);
            topRight.setX(topRight.getX()-anchorX);

            break;
        }
      var width = topRight.getX();
      var height = bottomLeft.getY();

        if(width && height) {
          image.setSize({width: width, height: height});
        }
        
        //to maintain the aspect ration 
        /* replace 
        	var width = topRight.getX() - topLeft.getX();
       	  var height = bottomLeft.getY() - topLeft.getY();
        	if(width && height) {
          	image.setSize(width, height);
        	}
        ...by
        	var height = bottomLeft.attrs.y - topLeft.attrs.y;
					var width = image.getWidth()*height/image.getHeight();
					topRight.attrs.x = topLeft.attrs.x + width;
					topRight.attrs.y = topLeft.attrs.y;
					bottomRight.attrs.x = topLeft.attrs.x + width;
					bottomRight.attrs.y = topLeft.attrs.y + height;
	
					if(width && height) {
						image.setSize(width, height);
					}
				*/ 
      }
function addAnchor(group, x, y, name) {
        var stage = group.getStage();
        var layer = group.getLayer();

        var anchor = new Kinetic.Circle({
          x: x,
          y: y,
          stroke: '#666',
          fill: '#ddd',
          strokeWidth: 1,
          radius: 8,
          name: name,
          draggable: true,
          dragOnTop: false
        });

        anchor.on('dragmove', function() {
          update(this);
          layer.draw();
        });
        anchor.on('mousedown touchstart', function() {
          group.setDraggable(false);
          this.moveToTop();
        });
        anchor.on('dragend', function() {
          group.setDraggable(true);
          layer.draw();
        });
        // add hover styling
        anchor.on('mouseover', function() {
          var layer = this.getLayer();
          document.body.style.cursor = 'pointer';
          this.setStrokeWidth(4);
          layer.draw();
        });
        anchor.on('mouseout', function() {
          var layer = this.getLayer();
          document.body.style.cursor = 'default';
          this.setStrokeWidth(2);
          layer.draw();
        });

        group.add(anchor);
      }