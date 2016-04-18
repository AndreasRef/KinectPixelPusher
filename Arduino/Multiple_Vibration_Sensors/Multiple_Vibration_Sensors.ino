//Communication from the Arduino vibration sensors to Processing 

int vibrationPins[] = {
  2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
};

int pinCount = 11;

int LED = 13;

int counter = 0;

void setup() {

  //Start serial
  Serial.begin(9600);

  // Define pin #13 as output, for the LED
  pinMode(LED, OUTPUT);

  // Define all pins in the vibrationPins array as inputs and activate the internal pull-up resistor
  for (int thisPin = 0; thisPin < pinCount; thisPin++) {
    pinMode(vibrationPins[thisPin], INPUT_PULLUP);
  }
}

void loop() {
  // Read the value of the input. It can either be 1 or 0
  for (int thisPin = 0; thisPin < pinCount; thisPin++) {

    int sensorValue = digitalRead(vibrationPins[thisPin]);

    if (sensorValue == LOW) { // If vibration trigger is down

      Serial.println(vibrationPins[thisPin]);
      digitalWrite(LED, HIGH);
      delay(300);

    } else {
      // Otherwise, turn the LED off
      digitalWrite(LED, LOW);
    }
  }
}
