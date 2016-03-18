//A tool that combines Kinect depth image and blob detection and lets you adjust settings with controlP5. 
//This sketch turns the floor into a grid sequencer - to be used with Max For Live device: MaxSequencerKinectPixelPusher.amxd 
//Additionally this sketch attempts to sync PixelPusher lights to music - works with the MaxSequencerKinectPixelPusher.amxd and KinectLightsAbleton.als

//REALLY MESSY RIGHT NOW, STILL WORK IN PROGRESS

//ORIGINAL EXAMPLES: 
//1) bd_webcam example --- Blob Detection Library --- http://www.v3ga.net/processing/BlobDetection/ 
//2) Depth threshold example --- OpenKinect Library --- https://github.com/shiffman/OpenKinect-for-Processing  
//3) Example 8 (about buttons), Chapther 33 -  Second Edition of Processing: A Programming Handbook for Visual Designers and Artists 

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import blobDetection.*;
import controlP5.*;
import oscP5.*;
import netP5.*;
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


//OSC
OscP5 oscP5;
NetAddress myRemoteLocation;

//Control p5
ControlP5 cp5;

// Kinect
Kinect kinect;
PImage depthImg;

//Blob
BlobDetection theBlobDetection;
PImage img;
boolean newFrame=false;

//ControlP5
int minDepth =  60; // Which pixels do we care about?
int maxDepth = 960; //914 

int programHeight = 480;
boolean positiveNegative = true;
boolean showBlobs = true;
boolean showEdges = true;
boolean showInformation = true;
boolean overControl = true;

float luminosityThreshold = 0.5;
float minimumBlobSize = 100;
int blurFactor = 30;


//Buttons
int horizontalSteps = 6;
int verticalSteps = 3;
int count;
int beatVal1 = 0;
//PVector control;

Button[] buttons;
boolean displayNumbers = true;
boolean autoPress = true;


void setup() {
  size(1280, 640); // Originally 1280 - main program runs 1280x480. The extra height is for controlP5 interface.

  //PixelPusher
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);

  //colorMode(HSB, 360);

  for (int i = 0; i <72*6; i++) {
    hue[i] = i;
    saturation[i] = 0;
    brightness[i]= 0;
  }

  //OSC
  oscP5 = new OscP5(this, 5002); // Listen for incoming messages at port 5002
  oscP5.plug(this, "beatPlug", "/beat");
  myRemoteLocation = new NetAddress("127.0.0.1", 5001); // set the remote location to be the localhost on port 5001

  //Kinect
  kinect = new Kinect(this);
  kinect.initDepth();
  depthImg = new PImage(kinect.width, kinect.height); // Blank image

  // BlobDetection
  // img which will be sent to detection (a smaller copy of the cam frame will propably be faster, but less accurate);
  img = new PImage(80*8, 60*8); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(luminosityThreshold); // will detect bright areas whose luminosity > luminosityThreshold (reverse if setPosDiscrimination(false);

  //ControlP5
  controlP5setup();

  //Button
  float w = 640/horizontalSteps;
  float h = 480/verticalSteps;

  count = horizontalSteps * verticalSteps;
  buttons = new Button[count];

  int index = 0;
  for (int i = 0; i < horizontalSteps; i++) { 
    for (int j = 0; j < verticalSteps; j++) {
      // Inputs: row, column, x, y, w, h , base color, over color, press color
      buttons[index++] = new Button(i, j, i*640/horizontalSteps, j*480/verticalSteps, w, h, color(122), color(255), color(0)); 
      //buttons[index++] = new Button(i, j, i*640/horizontalSteps, j*480/verticalSteps, w, h, color(122), color(122), color(122)); //If you don't want the changing colors
    }
  }
}

void draw() {
  // Draw the raw image
  //image(kinect.getDepthImage(), 0, 0);

  //Draw background rect
  noStroke();
  fill(0);
  rect(0, 0, width, height);

  // Threshold the depth image
  int[] rawDepth = kinect.getRawDepth();
  for (int i=0; i < rawDepth.length; i++) {
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      depthImg.pixels[i] = color(255);
    } else {
      depthImg.pixels[i] = color(0);
    }
  }

  img.copy(depthImg, 0, 0, depthImg.width, depthImg.height, 0, 0, img.width, img.height);
  fastblur(img, blurFactor);
  theBlobDetection.computeBlobs(img.pixels);
  drawBlobsAndEdges(showBlobs, showEdges, showInformation);
  theBlobDetection.setThreshold(luminosityThreshold); 
  theBlobDetection.activeCustomFilter(this);

  pushStyle();
  fill(255);
  textSize(24);
  textAlign(LEFT);
  text("BLOBS:" + theBlobDetection.getBlobNb(), 10, height- 30);
  popStyle();


  // Draw the thresholded image
  depthImg.updatePixels();
  image(depthImg, kinect.width, 0);

  pushStyle();
  for (Button button : buttons) {
    button.over=false;
    Blob b;
    //EdgeVertex eA, eB;
    for (int n=0; n<theBlobDetection.getBlobNb(); n++)
    {
      b=theBlobDetection.getBlob(n);

      button.update(b.xMin*width/2 + b.w*width/4, b.yMin*programHeight + b.h*programHeight/2);
    }
    if (autoPress) button.autoPress();
    button.display();
    if (displayNumbers) button.displayNumbers();
  }
  popStyle();


  OscMessage myMessage = new OscMessage("/sequencer");
  for (Button button : buttons) {
    myMessage.add(button.row);
    myMessage.add(button.column);
    //myMessage.add(button.state);

    //button.over instead of button.state

    if (overControl) {
      if (button.over) { //Overcontrol
        myMessage.add(1);
      } else {
        myMessage.add(0);
      }
    } else { //Statecontrol
      myMessage.add(button.state);
    }
  }
  oscP5.send(myMessage, myRemoteLocation); 

  //Beat marker line
  pushStyle();
  strokeWeight(10);
  stroke(255, 0, 0);
  line(beatVal1*640/horizontalSteps + 0.5*640/horizontalSteps, 0, beatVal1*640/horizontalSteps + 0.5*640/horizontalSteps, programHeight);
  popStyle();

  if (testObserver.hasStrips) {
    registry.startPushing();
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);
    strips = registry.getStrips();

    for (Button button : buttons) {
      if (overControl == true) {
        if (button.over && beatVal1 == button.row) {
          pushSide(5 - button.row, 2 - button.column, colorOptions[2 - button.column]); //Different colors
          //fadeSide(5 - button.row, 2 - button.column, colorOptions[2 - button.column], true, 1, 10);
        } else if (beatVal1 == button.row) {
          pushSide(5 - button.row, 2 - button.column, color(#050505)); //grey
          //fadeSide(5 - button.row, 2 - button.column, colorOptions[2 - button.column], false, 1, 0);
        } else {
          pushSide(5 - button.row, 2 - button.column, color(#000000)); //off
          //fadeSide(5 - button.row, 2 - button.column, colorOptions[2 - button.column], false, 1, 5);
        }
      } else if (overControl == false) {
        if (button.state==1 && beatVal1 == button.row) {
          pushSide(5 - button.row, 2 - button.column, colorOptions[2 - button.column]); //Different colors
        } else if (beatVal1 == button.row) {
          pushSide(5 - button.row, 2 - button.column, color(#050505)); //grey
        } else {
          pushSide(5 - button.row, 2 - button.column, color(#000000)); //off
        }
      }
    }
  }
}

//void mousePressed() {
//  if (mouseY < programHeight) {
//    for (Button button : buttons) {
//      button.press();
//    }
//  }
//}


public void beatPlug(int _beatVal1) {
  beatVal1 = _beatVal1;
  //println(beatVal1);
}

void pushSide(int strip, int side, color c) {
  for (int i = 0; i<strips.size(); i++) {
    for (int stripx = side*pixelsPerSide; stripx < (side+1)*pixelsPerSide; stripx++) {
      strips.get(strip).setPixel(c, stripx);
    }
  }
}


void fadeSide(int strip, int side, color c, boolean inOut, int fadeSpeed, int threshold) {
  pushStyle();
  colorMode(HSB, 360);
  for (int i = 0; i<strips.size(); i++) {
    for (int stripx = side*pixelsPerSide; stripx < (side+1)*pixelsPerSide; stripx++) {
      if (inOut == true) {
        brightness[stripx]+=fadeSpeed;
        if (brightness[stripx] >= 360) brightness[stripx] = 360;
      } else if (inOut ==false) {
        brightness[stripx]-=fadeSpeed;
        if (brightness[stripx] <= threshold) brightness[stripx] = threshold;
      }
      strips.get(strip).setPixel(color(hue(c), 360, brightness[stripx]), stripx);
    }
  }
  popStyle();
}