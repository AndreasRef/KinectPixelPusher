void controlP5setup() {

  int sliderHeight = 20;
  int sliderWidth = 150;
  int xOffset = 150;

  cp5 = new ControlP5(this);
  cp5.addToggle("showInformation").setPosition(45, programHeight +10).setSize(50, 20).listen(true);
  cp5.getController("showInformation").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(10);
  cp5.addToggle("showBlobs").setPosition(130, programHeight +10).setSize(50, 20).listen(true);
  cp5.getController("showBlobs").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(10);
  cp5.addToggle("showEdges").setPosition(215, programHeight +10).setSize(50, 20).listen(true);
  cp5.getController("showEdges").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(10);
  cp5.addSlider("luminosityThreshold", 0.0, 1.0, 150 + xOffset, programHeight + 10, sliderWidth, sliderHeight).listen(true);
  cp5.getController("luminosityThreshold").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(10);
  cp5.addSlider("minimumBlobSize", 0, 250, 350 + xOffset, programHeight + 10, sliderWidth, sliderHeight).listen(true);
  cp5.getController("minimumBlobSize").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(10);
  cp5.addSlider("blurFactor", 0, 50, 550 + xOffset, programHeight + 10, sliderWidth, sliderHeight).listen(true);
  cp5.getController("blurFactor").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(10);
  cp5.addSlider("minDepth", 0, 1000, 750 + xOffset, programHeight + 10, sliderWidth, sliderHeight).listen(true);
  cp5.getController("minDepth").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(10);
  cp5.addSlider("maxDepth", 0, 1000, 950 + xOffset, programHeight + 10, sliderWidth, sliderHeight).listen(true);
  cp5.getController("maxDepth").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(10);
  cp5.addToggle("overControl").setPosition(width - 175, height - 50).setSize(50, 20).listen(true);
  cp5.addBang("clearSeq").setPosition(width - 100, height-50).setSize(20, 20);
  cp5.addBang("reset", width -50, height-50, 20, 20);
}



public void reset() {
  minDepth =  60;
  maxDepth = 914;
  positiveNegative = true;
  showBlobs = true;
  showEdges = true;
  showInformation = true;
  luminosityThreshold = 0.5;
  minimumBlobSize = 100;
  blurFactor = 30;
  println("reset settings");
}

void clearSeq() {
  for (Button button : buttons) {
    button.state = 0;
    button.pressed = false;
  }
}