//A tool that combines 2 Kinect depth images with blob detection to control LED's via the PixelPusher //<>//
//Update 30/3: The sides are inverted which needs to be fixed!!

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

import blobDetection.*;

import controlP5.*;

import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;


//Pixelpusher
DeviceRegistry registry;

class TestObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    //println("Registry changed!");
    if (updatedDevice != null) {
      //println("Device change: " + updatedDevice);
    }
    this.hasStrips = true;
  }
}

TestObserver testObserver;
List<Strip> strips;

int sidesPerStrip = 3;
int stripNumbers = 6;
int pixelsPerStrip = 72;
int pixelsPerSide = 24;

int hue[] = new int[stripNumbers*pixelsPerStrip];
int saturation[] = new int[stripNumbers*pixelsPerStrip];
int brightness[] = new int[stripNumbers*pixelsPerStrip];

color[] colorOptions = { #003D43, #38001F, #8F7D00};

ControlP5 cp5;

//Kinect
ArrayList<Kinect> multiKinect;

int numDevices = 0;

PGraphics pg;

//DepthThreshold
PImage depthImg;

//Blob
BlobDetection theBlobDetection;
PImage img;
boolean newFrame=false;

int programHeight = 480; 

//ControlP5
int minDepth =  60;
int maxDepth = 914;

boolean positiveNegative = true;
boolean showBlobs = false;
boolean showEdges = true;
boolean showInformation = false;
float luminosityThreshold = 0.7;
float minimumBlobSize = 100;
int blurFactor = 6;
boolean mirror = true;
boolean rgbView = false;

int cropAmount = 9;

int kinect0X;
int kinect0Y;
int kinect1X;
int kinect1Y;



//Buttons
int startX = 0;
int startY = 0;
int endX = 1280;
int endY = 480;

int horizontalSteps = 6;
int verticalSteps = 3;
int count;
Button[] buttons;
boolean displayNumbers = true;
boolean autoPress = false;
boolean mouseControl = true;
boolean showButtons = true;

void setup() {
  size(1280, 640);

  //PixelPusher
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);


  pg = createGraphics(1280, 480); 

  numDevices = Kinect.countDevices();
  println("number of Kinect v1 devices  "+numDevices);

  multiKinect = new ArrayList<Kinect>();

  //iterate though all the devices and activate them
  for (int i  = 0; i < numDevices; i++) {
    Kinect tmpKinect = new Kinect(this);
    tmpKinect.enableMirror(mirror);
    tmpKinect.activateDevice(i);
    tmpKinect.initDepth();
    tmpKinect.initVideo();
    multiKinect.add(tmpKinect);
  }
  depthImg = new PImage(640, 480);

  // BlobDetection
  // img which will be sent to detection 
  img = new PImage(1280/4, 480/4); //a smaller copy of the frame is faster, but less accurate. Between 2 and 4 is normally fine
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(luminosityThreshold); // will detect bright areas whose luminosity > luminosityThreshold (reverse if setPosDiscrimination(false);

  //ControlP5
  cp5 = new ControlP5(this);
  controlP5setup();

  //Button
  setupButtons();
}

void draw() {
  background(0);

  pg.beginDraw();
  pg.background(0);
  for (int i  = 0; i < multiKinect.size(); i++) {
    //Kinect tmpKinect = (Kinect)multiKinect.get(i);
    //image(tmpKinect.getVideoImage(), 640*i, 0);
    multiKinect.get(i).enableMirror(mirror);

    //Threshold 
    int[] rawDepth = multiKinect.get(i).getRawDepth();
    for (int j=0; j < rawDepth.length; j++) {
      if (rawDepth[j] >= minDepth && rawDepth[j] <= maxDepth) {
        depthImg.pixels[j] = color(255);
      } else {
        depthImg.pixels[j] = color(0);
      }
    }
    depthImg.updatePixels();

    //Small hack for removing strange black bars in the left side of the depth images (might not be necessary for other setups)...
    //int cropAmount = 9;
    PImage croppedDepthImage = depthImg.get(cropAmount, 0, depthImg.width-cropAmount, depthImg.height);
    if (i==0) {
      pg.image(croppedDepthImage, croppedDepthImage.width*i+kinect0X, kinect0Y, croppedDepthImage.width, 480); //Be aware that this results in some empty (black) pixels all the way to the left
    } else if (i==1) {
      pg.image(croppedDepthImage, croppedDepthImage.width*i+kinect1X, kinect1Y, croppedDepthImage.width, 480); //Be aware that this results in some empty (black) pixels all the way to the left
    }
    //pg.image(depthImg, 640*i, 0); //Full image without crop
  }
  pg.endDraw();

  image(pg, 0, 0);


  img.copy(pg, 0, 0, pg.width, pg.height, 0, 0, img.width, img.height);
  fastblur(img, blurFactor);
  theBlobDetection.computeBlobs(img.pixels);
  drawBlobsAndEdges(showBlobs, showEdges, showInformation);
  theBlobDetection.setThreshold(luminosityThreshold); 
  theBlobDetection.activeCustomFilter(this);

  if (rgbView) {
    for (int i  = 0; i < multiKinect.size(); i++) {
      pushStyle();
      tint(255, 150);
      Kinect tmpKinect = (Kinect)multiKinect.get(i);
      image(tmpKinect.getVideoImage(), 640*i, 0);
      popStyle();
    }
  }  

  //Buttons
  pushStyle();
  for (Button button : buttons) {
    button.over=false;

    if (mouseControl) {
      button.update(mouseX, mouseY);
    } else {

      Blob b;
      for (int n=0; n<theBlobDetection.getBlobNb(); n++)
      {
        b=theBlobDetection.getBlob(n);

        button.update(b.xMin*width/1 + b.w*width/2, b.yMin*programHeight + b.h*programHeight/2);
      }
    }
    if (autoPress) button.autoPress();
    if (showButtons) { 
      button.display();
      if (displayNumbers) button.displayNumbers();
    }
  }
  popStyle();

  pushStyle();
  fill(255);
  textSize(16);
  textAlign(LEFT);
  text("BLOBS: " + theBlobDetection.getBlobNb(), 152, height-5);
  popStyle();


  //PixelPusher test

  if (testObserver.hasStrips) {
    registry.startPushing();
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);
    strips = registry.getStrips();

    //pushSide(1, 1, color(#050505)); //grey
        for (Button button : buttons) {
      //if (overControl == true) {
        if (button.over) {
          //pushSide(abs(5 - button.row), abs(2 - button.column), colorOptions[abs(2 - button.column)]); //Different colors
          pushSide(button.row, button.column, colorOptions[button.column]);
          //fadeSide(5 - button.row, 2 - button.column, colorOptions[2 - button.column], true, 1, 10);
        }  else {
          pushSide(button.row, button.column, color(#000000));
          //pushSide(abs(5 - button.row), abs(2 - button.column), color(#000000)); //off
          //fadeSide(5 - button.row, 2 - button.column, colorOptions[2 - button.column], false, 1, 5);
        }
      //} else if (overControl == false) {
      //  if (button.state==1 && beatVal1 == button.row) {
      //    pushSide(5 - button.row, 2 - button.column, colorOptions[2 - button.column]); //Different colors
      //  } else if (beatVal1 == button.row) {
      //    pushSide(5 - button.row, 2 - button.column, color(#050505)); //grey
      //  } else {
      //    pushSide(5 - button.row, 2 - button.column, color(#000000)); //off
      //  }
      }
    //}
    
    
  }
}