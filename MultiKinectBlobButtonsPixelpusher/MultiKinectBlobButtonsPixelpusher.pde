//A tool that combines 2 Kinect depth images with blob detection to control LED's via the PixelPusher //<>//

//Update 4/4: Added an index in the button class to make things easier, but actually not using it right now....??
// Figured out fading using the fadePixel function. KinectImage is flipped (and is too heavy on the frameRate to flip in code) 
// which is why I have a small hack using (2 - button.column)

//Update 5/4: Autopress not working anymore? 
//Experimenting with adding blobIndex to button class, so each person can have its own color...
// blob ID depends on X-position, which means that the blobs switch place... Pretty annoing....
// Maybe there is another way to make the blob get an ID at "birth" that doesn´t change

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

import blobDetection.*;

import controlP5.*;

import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

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
boolean showInfo = false;
float luminosityThreshold = 0.7;
float minimumBlobSize = 100;
int blurFactor = 6;
boolean mirror = true;
boolean rgbView = false;
boolean switchOrder = false;

int cropAmount = 9;

int kinect0X, kinect0Y, kinect1X, kinect1Y;

int c1H = 255;
int c1S = 255;
int c1B = 255;
int c2H = 255;
int c2S = 255;
int c2B = 255;
int c3H = 255;
int c3S = 255;
int c3B = 255;

int fadeInSpeed = 20;
int fadeOutSpeed = 10;

int autoPressTime = 1000;

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

    if (switchOrder) {
      if (i==0) {
        pg.image(croppedDepthImage, croppedDepthImage.width*(1-i)+kinect0X, kinect0Y, croppedDepthImage.width, 480); 
      } else if (i==1) {
        pg.image(croppedDepthImage, croppedDepthImage.width*(1-i)+kinect1X, kinect1Y, croppedDepthImage.width, 480); 
      }
    } else if (switchOrder == false) {
      if (i==0) {
        pg.image(croppedDepthImage, croppedDepthImage.width*i+kinect0X, kinect0Y, croppedDepthImage.width, 480); 
      } else if (i==1) {
        pg.image(croppedDepthImage, croppedDepthImage.width*i+kinect1X, kinect1Y, croppedDepthImage.width, 480); 
      }
      //pg.image(depthImg, 640*i, 0); //Full image without crop
    }
  }
  pg.endDraw();
  image(pg, 0, 0);


  img.copy(pg, 0, 0, pg.width, pg.height, 0, 0, img.width, img.height);
  fastblur(img, blurFactor);
  theBlobDetection.computeBlobs(img.pixels);
  drawBlobsAndEdges(showBlobs, showEdges, showInfo);
  theBlobDetection.setThreshold(luminosityThreshold); 
  theBlobDetection.activeCustomFilter(this);

  if (rgbView) {
    for (int i  = 0; i < multiKinect.size(); i++) {
      pushStyle();
      tint(255, 150);
      Kinect tmpKinect = (Kinect)multiKinect.get(i);

      if (switchOrder) {
        image(tmpKinect.getVideoImage(), 640*(1-i), 0); 
      } else {
        image(tmpKinect.getVideoImage(), 640*i, 0);
      }
      popStyle();
    }
  }  

  //Buttons
  pushStyle();
  for (Button button : buttons) {
    button.over=false;

    if (mouseControl) {
      button.update(mouseX, mouseY, 0); //blobIndex 0
    } else {

      Blob b;
      for (int n=0; n<theBlobDetection.getBlobNb(); n++)
      {
        b=theBlobDetection.getBlob(n);

        button.update(b.xMin*width/1 + b.w*width/2, b.yMin*programHeight + b.h*programHeight/2, n);
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

  colorMode(HSB, 255);
  noStroke();
  fill(c1H, c1S, c1B);
  rect(3*width/5 + 2 + 10, programHeight + 30, 110, 20);

  fill(c2H, c2S, c2B);
  rect(3*width/5 + 2 + 135, programHeight + 30, 110, 20);

  fill(c3H, c3S, c3B);
  rect(3*width/5 + 2 + 260, programHeight + 30, 110, 20);

  popStyle();

  //PixelPusher test

  pushStyle();
  colorMode(HSB, 255);
  colorOptions[0] = color(c1H, c1S, c1B);
  colorOptions[1] = color(c2H, c2S, c2B);
  colorOptions[2] = color(c3H, c3S, c3B);

  popStyle();

  if (testObserver.hasStrips) {
    registry.startPushing();
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);
    strips = registry.getStrips();

    //pushSide(1, 1, color(#050505)); //grey

    //fadeSide(1,1, colorOptions[0], false, 10, 10);

    pushStyle();
    colorMode(HSB, 360);
    
    //Fade in the selected SIDES and fade out all other SIDES using fadePixel function...
    for (Button button : buttons) {
      //int selectedSide = button.index;
      //if (button.over) {
      for (int i = 0; i<strips.size()*sidesPerStrip; i++) {
        if (2 - button.column + button.row*3 == i && button.over) { //Fade in selected strip
          for (int j=pixelsPerSide*i; j<pixelsPerSide*(i+1); j++) {
            fadePixel(j, colorOptions[button.column], true, fadeInSpeed, 0);
            //fadePixel(j, colorOptions[button.blobIndex % 3], true, fadeInSpeed, 0); //Controlled by blob index, so each blob has a unique color
          }
        } else if (2 - button.column + button.row*3 == i) { //Fade out all others
          for (int j=pixelsPerSide*i; j<pixelsPerSide*(i+1); j++) {
            fadePixel(j, colorOptions[button.column], false, fadeOutSpeed, 0);
            //fadePixel(j, colorOptions[button.blobIndex % 3], false, fadeOutSpeed, 0); //Controlled by blob index, so each blob has a unique color
          }
        }
      }
      }
          popStyle();

          for (Button button : buttons) {
            if (button.over) {
              //pushSide(button.row, 2 - button.column, colorOptions[button.column]); 
            } else {
              //pushSide(button.row, 2 - button.column, color(#000000));
            } 
          }
        }
      }