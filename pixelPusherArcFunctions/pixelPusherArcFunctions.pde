/*
PixelPusher arc control example by Andreas Refsgaard for Circus Family 2016
 
A set of functions for controlling led-strips which are connected in a formation of 6 arcs 
 
 ------------   
 |            | 
 |            | 
 |            | 
 |            | 
 |            |    x 6!
 
 
 Each tube has 24 pixels (because for some reason multiple (three or four?) LED's light up every time you assign a color to a pixel). 
 Therefore the pixels for each arc is ordered like this:
 
 ---24 25 26 ...............45 46 47---
 23                                 48
 21                                 49
 20                                 50
 (...)                              (...)
 (...)                              (...)
 (...)                              (...)
 2                                  69
 1                                  70
 0                                  71
 
 Side 1 pixels: 0-23
 Top pixels   : 24-47
 Side 2 pixels: 48-71
 
 To do:
 -> Make special functions
 *Blink
 *Rainbow
 *A way of keeping track of the current state of the arc/side/pixel
 
 */




//Delete these?
int[][] hues = {     
  {0, 20, 40}, 
  {60, 80, 100}, 
  {120, 140, 160}, 
  {180, 200, 220}, 
  {240, 260, 280}, 
  {300, 320, 340}    
};


//Global variables for the pixelPusher
int sidesPerStrip = 3;
int stripNumbers = 6;
int pixelsPerStrip = 72;
int pixelsPerSide = 24;

int hue[] = new int[stripNumbers*pixelsPerStrip];
int saturation[] = new int[stripNumbers*pixelsPerStrip];
int brightness[] = new int[stripNumbers*pixelsPerStrip];

int currentPixel = 0;

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


void setup() {
  size(240, 240, P2D); 

  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);

  colorMode(HSB, 360);

  for (int i = 0; i <72*6; i++) {
    hue[i] = i;
    saturation[i] = 0;
    brightness[i]= 0;
  }
}

void draw() {
  background(122);

  if (testObserver.hasStrips) {
    registry.startPushing();
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);
    strips = registry.getStrips();

    ////////EXAMPLES///////////////
    //color myColor = color(88, 360, 200); //Define color by HSB
    //color orange = color(#FF7A00); //Define color by HEX  

    //pushStrip(activeStrip, color(#FF7A00)); //Push whole strip
    //pushSide(0, 2, color(#FF7A00)); //Push single side (strip 0, side 2)



    //PushSides: Two dimensional array --- not sure about this one??
    //for (int i = 0; i<strips.size(); i++) {//Push single strips
    // for (int j = 0; j<sidesPerStrip; j++) {
    //   int hue =  hues[i][j];
    //   pushSide(i, j, color(hues[i][j], 360,360));
    //   if (hue > 360) hue = 0 ;
    //   hues[i][j]++;
    //   if (hues[i][j] == 360) hues[i][j]=0;
    // }
    //}

    //Set background: Should not run continiously in the draw loop - can produce flickering... It is better to integrate this in the functions where you also turn on stuff 
    //for (int i = 0; i<strips.size(); i++) {
    //pushStrip(i, color(10));
    //}

    //Push single pixels and turn off all other pixels
    //color pixelColor = color(int(map(currentPixel, 0, pixelsPerStrip*strips.size(), 0, 360)), 360, 360);
    //if (currentPixel >= pixelsPerStrip*strips.size()) currentPixel=0;
    //for (int i = 0; i< pixelsPerStrip*strips.size(); i++) {
    //  if (currentPixel == i) {
    //    pushPixel(currentPixel, pixelColor);
    //  } else {
    //    pushPixel(i, color(0));
    //  }
    //}
    //currentPixel++;


    //Push multiple pixels (changing colors rainbowstyle)
    //for (int i = 0; i<pixelsPerStrip*strips.size(); i++) {
    //  pushStyle(); //Changing colorMode to compesentate for having 432 LED's
    //  colorMode(HSB, pixelsPerStrip*strips.size());
    //  int currentHue =  hue[i];
    //  pushPixel(i, color(currentHue, saturation[i], brightness[i]));
    //  //pushPixel(i, color(currentHue, pixelsPerStrip*strips.size(), pixelsPerStrip*strips.size()));
    //  hue[i]+=1;
    //  if (hue[i] >pixelsPerStrip*strips.size()) hue[i] = 0;
    //  popStyle();
    //}

    //Fade in / out with mouse buttons
    //if (mousePressed) {
    //  if (mouseButton == LEFT) {
    //    //fadeStrip(0, color(#FF7A00), true); //Fade single strip in
    //    for (int i=pixelsPerStrip*2; i<pixelsPerStrip*3; i++) {
    //      fadePixel(i, color(#FF7A00), true, 5);
    //    }
    //  } else if (mouseButton == RIGHT) {
    //    //fadeStrip(0, color(#FF7A00), false); //Fade single strip out
    //    for (int i=pixelsPerStrip*2; i<pixelsPerStrip*3; i++) {
    //      fadePixel(i, color(#FF7A00), false, 10);
    //    }
    //  }
    //}



    //Fade in the selected STRIP and fade out all other STRIPS...
    //int selectedStrip = floor(map(mouseX, 0, width, 0, 6));
    //for (int i = 0; i<strips.size(); i++) {
    //  if (selectedStrip == i) { //Fade in selected strip
    //    for (int j=pixelsPerStrip*i; j<pixelsPerStrip*(i+1); j++) {
    //      fadePixel(j, color(#FF7A00), true, 10);
    //    }
    //  } else { //Fade out all others
    //    for (int j=pixelsPerStrip*i; j<pixelsPerStrip*(i+1); j++) {
    //      fadePixel(j, color(#FF7A00), false, 5);
    //    }
    //  }
    //}
    
    
    
     //Fade in the selected SIDES and fade out all other SIDES...
    int selectedSide = floor(map(mouseX, 0, width, 0, 6*3));
    for (int i = 0; i<strips.size()*sidesPerStrip; i++) {
      if (selectedSide == i) { //Fade in selected strip
        for (int j=pixelsPerSide*i; j<pixelsPerSide*(i+1); j++) {
          fadePixel(j, color(#6ADDFF), true, 20, 10);
        }
      } else { //Fade out all others
        for (int j=pixelsPerSide*i; j<pixelsPerSide*(i+1); j++) {
          fadePixel(j, color(#6ADDFF), false, 5,10);
        }
      }
    }
    
    
    ////////END OF EXAMPLES///////////////
  }
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


void pushStrip(int strip, color c) {
  for (int i = 0; i<strips.size(); i++) {
    for (int stripx = 0; stripx < pixelsPerStrip; stripx++) {
      strips.get(strip).setPixel(c, stripx);
    }
  }
}

void pushSide(int strip, int side, color c) {
  for (int i = 0; i<strips.size(); i++) {
    for (int stripx = side*pixelsPerSide; stripx < (side+1)*pixelsPerSide; stripx++) {
      strips.get(strip).setPixel(c, stripx);
    }
  }
}

void pushPixel(int pixel, color c) {
  int strip = floor(pixel/(pixelsPerStrip));
  int pixelNum = pixel % (pixelsPerStrip);

  for (int i = 0; i<strips.size(); i++) {
    strips.get(strip).setPixel(c, pixelNum);
  }
}

void keyPressed() {
  for (int i = 0; i<strips.size(); i++) {
    pushStrip(i, color(10));
  } 
  for (int i = 0; i <72*6; i++) {
    hue[i] = i;
    saturation[i] = 0;
    brightness[i]= 0;
  }
}