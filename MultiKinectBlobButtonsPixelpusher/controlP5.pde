void controlP5setup() {

  //Shared dimensions
  int toogleWidth = 50;
  int toogleHeight = 20;
  int sliderHeight = 10;
  int sliderWidth = 100;
  int xOffset = 2;
  int yOffset = 20;

  //Blob GUI
  Group BlobControls = cp5.addGroup("BlobControls")
    .setPosition(0 + xOffset, programHeight + yOffset)
    .setSize(width/5 - xOffset*2, height-programHeight-yOffset)
    .setBackgroundColor(color(255, 50))
    ;

  cp5.addToggle("showInfo").setPosition(10, 10).setSize(toogleWidth, toogleHeight).setGroup(BlobControls).listen(true);
  cp5.addToggle("showBlobs").setPosition(10, 50).setSize(toogleWidth, toogleHeight).setGroup(BlobControls).listen(true);
  cp5.addToggle("showEdges").setPosition(10, 90).setSize(toogleWidth, toogleHeight).setGroup(BlobControls).listen(true);
  cp5.addSlider("luminosityThreshold", 0.0, 1.0).setCaptionLabel("lumThres").setPosition(90, 10).setSize(sliderWidth, sliderHeight).setGroup(BlobControls).listen(true);
  cp5.addSlider("minimumBlobSize", 0, 250).setCaptionLabel("minSize").setPosition(90, 45).setSize(sliderWidth, sliderHeight).setGroup(BlobControls).listen(true);
  cp5.addSlider("blurFactor", 0, 50).setPosition(90, 80).setSize(sliderWidth, sliderHeight).setGroup(BlobControls).listen(true);

  //Kinect GUI
  Group KinectControls = cp5.addGroup("KinectControls")
    .setPosition(width/5 + xOffset, programHeight + yOffset)
    .setSize(width/5 - xOffset*2, height-programHeight-yOffset )
    .setBackgroundColor(color(255, 50))
    ;

  cp5.addSlider("minDepth", 0, 1000, 10, 10, sliderWidth-25, sliderHeight).setGroup(KinectControls).listen(true);
  cp5.addSlider("maxDepth", 0, 1000, 10, 30, sliderWidth-25, sliderHeight).setGroup(KinectControls).listen(true);
  cp5.addSlider("cropAmount", 0, 50, 160, 130, sliderWidth-75, sliderHeight).setGroup(KinectControls).listen(true);

  cp5.addToggle("mirror").setPosition(160, 10).setSize(toogleWidth, toogleHeight).setGroup(KinectControls).listen(true);
  cp5.addToggle("rgbView").setPosition(160, 50).setSize(toogleWidth, toogleHeight).setGroup(KinectControls).listen(true);
  cp5.addToggle("switchOrder").setPosition(160, 90).setSize(toogleWidth, toogleHeight).setGroup(KinectControls).listen(true);
  
  cp5.addSlider("kinect0X", -100, 100, 10, 50, sliderWidth-25, sliderHeight).setGroup(KinectControls).listen(true);
  cp5.addSlider("kinect0Y", -100, 100, 10, 70, sliderWidth-25, sliderHeight).setGroup(KinectControls).listen(true);

  cp5.addSlider("kinect1X", -100, 100, 10, 90, sliderWidth-25, sliderHeight).setGroup(KinectControls).listen(true);
  cp5.addSlider("kinect1Y", -100, 100, 10, 110, sliderWidth-25, sliderHeight).setGroup(KinectControls).listen(true);

  //Buttons GUI
  Group ButtonControls = cp5.addGroup("ButtonControls")
    .setPosition(2*width/5 + xOffset, programHeight + yOffset)
    .setSize(width/5 - xOffset*2, height-programHeight-yOffset )
    .setBackgroundColor(color(255, 50))
    ;

  cp5.addSlider("autoPressTime", 200, 2000).setCaptionLabel("autoTime").setPosition(160, 10).setSize(toogleWidth, toogleHeight/2).setGroup(ButtonControls);
  cp5.addToggle("autoPress").setPosition(160, 30).setSize(toogleWidth, toogleHeight/2).setGroup(ButtonControls).listen(true);
  cp5.addToggle("mouseControl").setPosition(160, 60).setSize(toogleWidth, toogleHeight/2).setGroup(ButtonControls).listen(true);
  cp5.addToggle("showButtons").setPosition(160, 90).setSize(toogleWidth, toogleHeight/2).setGroup(ButtonControls).listen(true);
  cp5.addButton("clearSeq").setPosition(195, 120).setSize(toogleWidth, toogleHeight/2).setGroup(ButtonControls).setColorBackground(color(0, 100, 50)); 
  cp5.addSlider("horizontalSteps", 0, 10).setCaptionLabel("rows").setPosition(10, 10).setGroup(ButtonControls);
  cp5.addSlider("verticalSteps", 0, 10).setCaptionLabel("cols").setPosition(10, 30).setGroup(ButtonControls);

  cp5.addSlider("startX", 0, 640).setPosition(10, 60).setGroup(ButtonControls);
  cp5.addSlider("startY", 0, 240).setPosition(10, 80).setGroup(ButtonControls);
  cp5.addSlider("endX", 640, 1280).setPosition(10, 100).setGroup(ButtonControls);
  cp5.addSlider("endY", 240, 480).setPosition(10, 120).setGroup(ButtonControls);

 

  //PixelPusher GUI
  Group PixelPusherControls = cp5.addGroup("PixelPusherControls")
    .setPosition(3*width/5 + xOffset, programHeight + yOffset)
    .setSize(2* width/5 - xOffset*4 - 100, height-programHeight-yOffset )
    .setBackgroundColor(color(255, 50))
    ;


  cp5.addSlider("c1H", 0, 255).setPosition(10, 40).setGroup(PixelPusherControls);
  cp5.addSlider("c1S", 0, 255).setPosition(10, 60).setGroup(PixelPusherControls);
  cp5.addSlider("c1B", 0, 255).setPosition(10, 80).setGroup(PixelPusherControls);

  cp5.addSlider("c2H", 0, 255).setPosition(135, 40).setGroup(PixelPusherControls);
  cp5.addSlider("c2S", 0, 255).setPosition(135, 60).setGroup(PixelPusherControls);
  cp5.addSlider("c2B", 0, 255).setPosition(135, 80).setGroup(PixelPusherControls);

  cp5.addSlider("c3H", 0, 255).setPosition(260, 40).setGroup(PixelPusherControls);
  cp5.addSlider("c3S", 0, 255).setPosition(260, 60).setGroup(PixelPusherControls);
  cp5.addSlider("c3B", 0, 255).setPosition(260, 80).setGroup(PixelPusherControls);
  
  

  cp5.addSlider("fadeInSpeed", 0, 50).setPosition(10, 120).setGroup(PixelPusherControls); 
  cp5.addSlider("fadeOutSpeed", 0, 50).setPosition(170, 120).setGroup(PixelPusherControls); 
  
  
  cp5.addButton("clearLights").setPosition(350, 120).setSize(toogleWidth, toogleHeight/2).setGroup(PixelPusherControls).setColorBackground(color(0, 100, 50));

  //Settings GUI
  Group SettingsControls = cp5.addGroup("SettingsControls")
    .setPosition(width - xOffset - 100, programHeight + yOffset)
    .setSize(100, height-programHeight-yOffset )
    .setBackgroundColor(color(255, 50))
    ;

  cp5.addButton("b3", 10, 10, 10, 80, 12).setCaptionLabel("save default").setGroup(SettingsControls);
  cp5.addButton("b4", 10, 10, 40, 80, 12).setCaptionLabel("load default").setGroup(SettingsControls).setColorBackground(color(0, 100, 50));

  //cp5.loadProperties(("default.json")); //Load saved settings - overwrites ranges (!)

  //FrameRate
  cp5.addFrameRate().setInterval(10).setPosition(width-20, height - 10);
}


void b3(float v) {
  cp5.saveProperties("default", "default");
}

void b4(float v) {
  cp5.loadProperties(("default.json"));
}


void clearSeq() {
  for (Button button : buttons) {
    button.state = 0;
    button.pressed = false;
  }
}

void controlEvent(ControlEvent theEvent) {

  if (theEvent.isFrom(cp5.getController("horizontalSteps")) 
    || theEvent.isFrom(cp5.getController("verticalSteps"))
    || theEvent.isFrom(cp5.getController("startX"))
    || theEvent.isFrom(cp5.getController("startY"))
    || theEvent.isFrom(cp5.getController("endX"))
    || theEvent.isFrom(cp5.getController("endY"))  ) {
    setupButtons();
  }
}