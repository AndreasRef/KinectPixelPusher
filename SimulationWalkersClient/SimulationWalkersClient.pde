//This sketch is the Client of the Server-Client relationship. 
//Its purpose is ONLY to send information about which buttons 
//in the second half of the installation where "over == true"

//It still needs to be integrated with the Kinect

// Import the net libraries
import processing.net.*;
// Declare a client
Client client;

import controlP5.*;
ControlP5 cp5;

//Buttons
int horizontalSteps = 8;
int verticalSteps = 7;
int count;
Button[] buttons;
boolean displayNumbers = true;
boolean displayButtons = true;

int programHeight = 480;

ArrayList<Walker> walkers;

int yOffset = 100;
int speed = 50;

color gradientStart;
color gradientEnd;
color currentBeatC;
color triggerC;

void setup() {
  size(1280, 800);
  
  frameRate(30);
  
  client = new Client(this, "192.168.10.118", 5204);

  walkers = new ArrayList<Walker>();

  cp5 = new ControlP5(this);
  cp5.addSlider("horizontalSteps", 0, 16).setPosition(10, height-55);
  cp5.addSlider("verticalSteps", 0, 8).setPosition(10, height-35);
  cp5.addSlider("speed", 0, 50).setPosition(10, height-15);

  cp5.addToggle("displayNumbers").setPosition(200, height-55).setSize(50, 10);
  cp5.addToggle("displayButtons").setPosition(200, height-25).setSize(50, 10);
 
  setupButtons();
}

void draw() {
  background(50);

  for (Button button : buttons) {
    button.over=false;
    //button.update(mouseX, mouseY); //Update using mouse
    for (int i = 0; i < walkers.size(); i++) { //Update using random walkers
      Walker w = walkers.get(i);
      button.update(w.location.x, w.location.y);
    }
    //client.write(str(int(button.over)) + " ");
    if (displayButtons) button.display();
    if (displayNumbers) button.displayNumbers();
  }
  
  
  for (int i = 0; i<7*8; i++) {
  client.write(str(int(buttons[i].over)) + " ");
  }

  for (int i = 0; i < walkers.size(); i++) {
    Walker w = walkers.get(i);
    w.walk();
    w.display();
  }
}


void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(cp5.getController("horizontalSteps")) || theEvent.isFrom(cp5.getController("verticalSteps"))) {
    setupButtons();
  }
}


void keyPressed() {
  if (key == 'a') walkers.add(new Walker((int)random(width), (int)random(programHeight)+yOffset)); 
  if (key == 'd' && walkers.size() > 0)  walkers.remove(0);
}

void setupButtons () {
  count = horizontalSteps * verticalSteps;
  buttons = new Button[count];

  int index = 0;
  for (int i = 0; i < horizontalSteps; i++) { 
    for (int j = 0; j < verticalSteps; j++) {
      buttons[index] = new Button(index, i, j, i*1280/horizontalSteps, j*programHeight/verticalSteps+yOffset, 1280/horizontalSteps, 480/verticalSteps, color(122), color(255));
      index++;  
    }
  }
}


void mousePressed() {
  if (mouseY > yOffset && mouseY < yOffset + programHeight) {
    walkers.add(new Walker(mouseX, mouseY));
  }
}