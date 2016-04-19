int sensorPin = 12;
int LED = 13;

int counter = 0;

void setup() {
  
  //Start serial
  Serial.begin(9600);
  
  // Define pin #12 as input and activate the internal pull-up resistor
  pinMode(sensorPin, INPUT_PULLUP);
  
  // Define pin #13 as output, for the LED
  pinMode(LED, OUTPUT);
}

void loop(){
  // Read the value of the input. It can either be 1 or 0
  int sensorValue = digitalRead(sensorPin);
  
  if (sensorValue == LOW){// If vibration trigger is down
    digitalWrite(LED, HIGH);
    Serial.println(counter);
    counter = counter+1;
    delay(300); //Should perhaps be removed
  } else {
    // Otherwise, turn the LED off
    digitalWrite(LED, LOW);
  } 
}
