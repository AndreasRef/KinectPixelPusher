//This sketch simulates people walking around in the tunnel. 

//Updates

//April 11th: 
//Light is now in a class, but not connected to the Pixelpusher yet. 
//Sound is connected to Ableton via Max for Live. Works well. Kinect is not connected yet. 

//To do: 
//Push to Github

import controlP5.*;
ControlP5 cp5;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

//Buttons
int horizontalSteps = 16;
int verticalSteps = 7;
int count;
Button[] buttons;
boolean displayNumbers = false;
boolean displayButtons = false;

//boolean autoPress = false;
boolean whiteLights = true;

int programHeight = 480;

int beatVal1 = 0;

ArrayList<Walker> walkers;
float walkerSteps = 2;

int yOffset = 100;
int speed = 50;

Light[] lights = new Light[horizontalSteps];

color c1;
color c2;

void setup() {
  size(1280, 800);
  walkers = new ArrayList<Walker>();

  oscP5 = new OscP5(this, 5002); // Listen for incoming messages at port 5002
  oscP5.plug(this, "beatPlug", "/beat");

  myRemoteLocation = new NetAddress("127.0.0.1", 5001); // set the remote location to be the localhost on port 5001

  OscMessage bangMessage = new OscMessage("/bang"); //Start the metro
  bangMessage.add(1);
  oscP5.send(bangMessage, myRemoteLocation);

  cp5 = new ControlP5(this);
  cp5.addSlider("horizontalSteps", 0, 16).setPosition(10, height-55);
  cp5.addSlider("verticalSteps", 0, 8).setPosition(10, height-35);
  cp5.addSlider("speed", 0, 50).setPosition(10, height-15);

  cp5.addToggle("displayNumbers").setPosition(200, height-55).setSize(50, 10);
  cp5.addToggle("displayButtons").setPosition(200, height-25).setSize(50, 10);
  cp5.addToggle("whiteLights").setPosition(325, height-55).setSize(50, 10);

  cp5.addColorWheel("c1", 400, height - 115, 100 ).setRGB(color(#71FFD6));
  cp5.addColorWheel("c2", 520, height - 115, 100 ).setRGB(color(#FA0DFF));

  setupButtons();

  //lights
  for (int i=0; i<lights.length; i++) {
    lights[i] = new Light(i, 255, 255, 255, false, false, color(#FC03C3)); //Pink
  }
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
    //if (autoPress) button.autoPress();
    if (displayButtons) button.display();
    if (displayNumbers) button.displayNumbers();
  }


  OscMessage myMessage = new OscMessage("/sequencer");
  for (Button button : buttons) {
    myMessage.add(button.row);
    myMessage.add(button.column);
    if (button.over) {
      myMessage.add(1);
    } else {
      myMessage.add(0);
    }
  }
  oscP5.send(myMessage, myRemoteLocation);

  for (int i = 0; i < walkers.size(); i++) {
    Walker w = walkers.get(i);
    w.walk();
    w.display();
  }

  strokeWeight(25);
  stroke(255, 0, 0);
  //line(beatVal1*width/horizontalSteps + 0.5*width/horizontalSteps, yOffset, beatVal1*width/horizontalSteps + 0.5*width/horizontalSteps, programHeight+yOffset);
  strokeWeight(1);

  pushStyle();
  colorMode(HSB, 255);
  drawLights();
  popStyle();
}

void drawLights() {

  noStroke();
  for (int i = 0; i<lights.length; i++) {
    lights[i].fillC = color(hue(lerpColor(c1, c2, abs(200 - (frameCount % 400))*0.005)), 75, 75);
    
    for (Button button : buttons) {
        if (button.row == i && button.over) {
        if (whiteLights) {
          lights[i].fillC = color (#FFFFFF,120);
          
        } else {
          lights[i].fillC = color (hue(lerpColor(c1, c2, abs(200 - (frameCount % 400))*0.005)), 255, 255);
        }
        
        if (beatVal1 == i) {
          lights[i].fillC = color (#FFFFFF); // White

        }
      } else {
      }
    }
    
    lights[i].display();
    
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
        // Inputs: row, column, x, y, w, h , base color, over color, press color
        //buttons[index++] = new Button(i, j+yOffset, i*1280/horizontalSteps, j*programHeight/verticalSteps+yOffset, 1280/horizontalSteps, 480/verticalSteps, color(122), color(255), color(0));
        buttons[index++] = new Button(i, j, i*1280/horizontalSteps, j*programHeight/verticalSteps+yOffset, 1280/horizontalSteps, 480/verticalSteps, color(122), color(255), color(0));
      }
    }
  }


  void mousePressed() {
    if (mouseY > yOffset && mouseY < yOffset + programHeight) {
      walkers.add(new Walker(mouseX, mouseY));
    }
  }


  public void beatPlug(int _beatVal1) {
    beatVal1 = _beatVal1;
    //println(_beatVal1);
  }