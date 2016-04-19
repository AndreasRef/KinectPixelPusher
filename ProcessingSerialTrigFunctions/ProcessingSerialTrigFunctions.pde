//This Sketch is a demo that shows how to take incomming Arduino Sensor values from the serial port 
//(from Multiple_Vibration_Sensors.ino)  
//And use them to trig notes in Ableton via Max4Live patch PlaySingleDynamicDuration.amxd
//Its functionality should be integrated into SimulationWalkersServer.pde

import netP5.*;
import processing.serial.*;

import oscP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

Serial myPort;
int serialCounter = 0;
int lastSerialCounter =0;

int triggerValue = 0;

void setup() {
  size(400, 400);
  println(Serial.list());

  oscP5 = new OscP5(this, 12000);

  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil('\n');

  myRemoteLocation = new NetAddress("127.0.0.1", 5001);
}

void draw() {

  if (lastSerialCounter == serialCounter) {
    // Do nothing
  } else {
    trigFunction();
  }
  lastSerialCounter = serialCounter;
}

void serialEvent(Serial thisPort) {
  String inputString = thisPort.readStringUntil('\n');
  inputString = trim(inputString);
  triggerValue = int(inputString);

  serialCounter++;
}

void trigFunction() {
  fill(triggerValue *20);
  rect(random(width), random(height), 20, 20); 

  println("New trig revieced from input " + triggerValue);
  println("Total trigs recieved " + serialCounter);
  println();

  int midiNote = int(random(65, 80));

  OscMessage myMessage = new OscMessage("/note");
  myMessage.add(midiNote); 
  myMessage.add(122); 
  oscP5.send(myMessage, myRemoteLocation); 

  OscMessage myMessageOff = new OscMessage("/note");
  myMessageOff.add(midiNote); 
  myMessageOff.add(0); 
  oscP5.send(myMessageOff, myRemoteLocation);
}