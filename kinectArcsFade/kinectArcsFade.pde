/*First working lofi-prototype 
 
 Works by measuring the distance between the kinect and the closest point 
 within a defined area of interest
 
 Attemt to implement fading in the arcs 
 
 */


//PixelPusher_archControl_simple
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

DeviceRegistry registry;


class TestObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    println("Registry changed!");
    if (updatedDevice != null) {
      println("Device change: " + updatedDevice);
    }
    this.hasStrips = true;
  }
}

TestObserver testObserver;
List<Strip> strips;

//Doesn't work every other time because of the Kinect Model... See this issue: https://github.com/shiffman/OpenKinect-for-Processing/issues/45

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

int colOffset = 190;
int rowOffsetBottom = 220;
int rowOffsetTop = 20;


//Global variables for the pixelPusher
int sidesPerStrip = 3;
int stripNumbers = 6;
int pixelsPerStrip = 72;
int pixelsPerSide = 24;

int hue[] = new int[stripNumbers*pixelsPerStrip];
int saturation[] = new int[stripNumbers*pixelsPerStrip];
int brightness[] = new int[stripNumbers*pixelsPerStrip];

int currentPixel = 0;


void setup() {
  size(640, 580);

  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);


  kinect = new Kinect(this);
  tracker = new KinectTracker();

  colorMode(HSB, 360);

  for (int i = 0; i <72*6; i++) {
    hue[i] = i;
    saturation[i] = 0;
    brightness[i]= 0;
  }
}

void draw() {
  background(255);

  //scale((float)width/640.0); //Scale everything against the reference resolution. Makes frameRate drop to 10
  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();


  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  fill(50, 100, 250, 200);
  noStroke();
  ellipse(v1.x, v1.y, 20, 20);

  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  fill(100, 250, 50, 200);
  noStroke();
  ellipse(v2.x, v2.y, 20, 20);


  // Let's draw the "closest" location
  PVector v3 = tracker.getClosestPos();
  fill(250, 50, 50, 200);
  noStroke();
  ellipse(v3.x, v3.y, 20, 20);


  // Let's draw the "closest" location
  PVector v4 = tracker.getLerpedClosestPos();
  fill(250, 0, 250, 200);
  noStroke();
  ellipse(v4.x, v4.y, 20, 20);



  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 500);
  text("*COLORS* \n Red: Closest Point - Magenta: Closest Point Lerped - Green: Average Point - Blue: Average Point Lerped ", 10, 530);

  //Draw lines that define Area Of Interest
  pushStyle();
  stroke(255, 0, 0);
  strokeWeight(5);
  line(colOffset, 0, colOffset, height);
  line(width - colOffset, 0, width - colOffset, 480);

  line(0, rowOffsetTop, width, rowOffsetTop);
  line(0, 480 - rowOffsetBottom, width, 480- rowOffsetBottom);

  textSize(54);
  fill(255);
  textAlign(CENTER);
  text(tracker.lerpedWorldRecordClosest, width/2, height/2);
  text(lightStates(), width/2, height/2 + 100);
  //lightStates
  popStyle();


  int activeStrip = int(map(mouseX, 0, width, 5, -1));
  text(activeStrip, width/2, height/2);

  if (testObserver.hasStrips) {
    registry.startPushing();
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);
    strips = registry.getStrips();

    color orange = color(255, 122, 0);
    color grey = color(20, 20, 20);
    
    for (int i = 0; i<strips.size(); i++) {
     if (lightStates() == i) { //Fade in selected strip
       for (int j=pixelsPerStrip*i; j<pixelsPerStrip*(i+1); j++) {
         fadePixel(j, color(#FF7A00), true, 10, 5);
       }
     } else { //Fade out all others
       for (int j=pixelsPerStrip*i; j<pixelsPerStrip*(i+1); j++) {
         fadePixel(j, color(#FF7A00), false, 5, 5);
       }
     }
    }    
  }
}



// Adjust the threshold with key presses
void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
    }
  }
}

int lightStates() {
  int currentState = 0;

  if (tracker.lerpedWorldRecordClosest < 720) {
    currentState = -1;
  } else if (tracker.lerpedWorldRecordClosest < 830) {
    currentState = 5;
  } else if (tracker.lerpedWorldRecordClosest < 890) {
    currentState = 4;
  } else if (tracker.lerpedWorldRecordClosest < 923) {
    currentState = 3;
  } else if (tracker.lerpedWorldRecordClosest < 950) {
    currentState = 2;
  } else if (tracker.lerpedWorldRecordClosest < 967) {
    currentState = 1;
  } else if (tracker.lerpedWorldRecordClosest < 982) {
    currentState = 0;
  } else {
    currentState = -1;
  }
  return currentState;
}


void fadePixel(int pixel, color c, boolean inOut, int fadeSpeed, int threshold) { 
  int strip = floor(pixel/(pixelsPerStrip));
  int pixelNum = pixel % (pixelsPerStrip);

  if (inOut == true) {
    brightness[pixel]+=fadeSpeed;
    if (brightness[pixel] >= 360) brightness[pixel] = 360;
  } else if (inOut ==false) {
    brightness[pixel]-=fadeSpeed;
    if (brightness[pixel] <= threshold) brightness[pixel] = threshold;
  }
  for (int i = 0; i<strips.size(); i++) {
    strips.get(strip).setPixel(color(hue(c), 360, brightness[pixel]), pixelNum);
  }
}