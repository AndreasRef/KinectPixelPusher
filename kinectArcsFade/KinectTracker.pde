// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

class KinectTracker {

  int worldRecordClosest;
  int lerpedWorldRecordClosest;
  
  // Depth threshold
  int threshold = 745;

  // Raw location
  PVector loc;

  // Interpolated location
  PVector lerpedLoc;

  // Closest location
  PVector closestLoc;

  // Closest location interpolated
  PVector lerpedClosestLoc;

  // Depth data
  int[] depth;

  // What we'll show the user
  PImage display;

  KinectTracker() {
    // This is an awkard use of a global variable here
    // But doing it this way for simplicity
    kinect.initDepth();
    kinect.enableMirror(true);
    // Make a blank image
    display = createImage(kinect.width, kinect.height, RGB);
    // Set up the vectors
    loc = new PVector(0, 0);
    lerpedLoc = new PVector(0, 0);

    closestLoc = new PVector(0, 0);
    lerpedClosestLoc = new PVector(0, 0);
  }

  void track() {
    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;

    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset =  x + y*kinect.width;
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against threshold
        if (rawDepth < threshold) {
          sumX += x;
          sumY += y;
          count++;
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count, sumY/count);
    }

    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f);


    //what is the x y of the closes pixel to the camera?
    //int[ ] allDepths = new int[640*480];
    //context.depthMap(allDepths );
    worldRecordClosest = 100000;
    int winX =0;
    int winY= 0;

    //Attempting to reduce Area Of Interest to only be the middle of the screen

    //for (int row = 0; row < 480; row++) {
    for (int row = rowOffsetTop; row < 480 - rowOffsetBottom; row++) {
      for (int col = colOffset; col < 640 - colOffset; col++) {
        int placeInBigArray = row*640 + col;
        if (depth[placeInBigArray] < worldRecordClosest && depth[placeInBigArray] != 0 ) {
          worldRecordClosest = depth[placeInBigArray];
          winX= col;
          winY = row;
          closestLoc.x = col;
          closestLoc.y = row;
        }
      }
    }
    
    lerpedWorldRecordClosest = (int)PApplet.lerp(lerpedWorldRecordClosest, worldRecordClosest, 0.2f);
    
    lerpedClosestLoc.x = PApplet.lerp(lerpedClosestLoc.x, closestLoc.x, 0.03f);
    lerpedClosestLoc.y = PApplet.lerp(lerpedClosestLoc.y, closestLoc.y, 0.03f);

    println(worldRecordClosest);
  }





  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }


  PVector getClosestPos() {
    return closestLoc;
  }


  PVector getLerpedClosestPos() {
    return lerpedClosestLoc;
  }



  void display() {
    PImage img = kinect.getDepthImage();

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset = x + y * kinect.width;
        // Raw depth
        int rawDepth = depth[offset];
        int pix = x + y * display.width;
        if (rawDepth < threshold) {
          // A red color instead
          display.pixels[pix] = color(150, 50, 50);
        } else {
          display.pixels[pix] = img.pixels[offset];
        }
      }
    }
    display.updatePixels();

    // Draw the image
    pushMatrix();
    //scale((float)width/640.0); //Makes framerate drop
    //image(display, 0, 0, kinect.width*width/640.0, kinect.height*width/640.0); //Makes framerate drop
    image(display, 0, 0);
    popMatrix();
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }
}