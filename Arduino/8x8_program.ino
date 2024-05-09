#include <avr/wdt.h>
#define Vi 5
#define avr 20 //Average
#define MAX_DIMENSION 8

int selectors[8] = { 0 };
int n = 0;
bool Activate = false;

void setup() {
  Serial.begin(115200);
// Set selector outputs
  for (int pin = 2; pin <= 7; pin++) pinMode(pin, OUTPUT);
  Serial.println("Plot starting up");
}

// Function to write selector outputs
void setPins(int value, int basePin) {
  for (int i = 0; i < 3; i++) {
    int pin = basePin - i + 2;
    int newValue = (value & (1 << i)) ? HIGH : LOW;
    if (selectors[pin] != newValue) {
      digitalWrite(pin, newValue);
      selectors[pin] = newValue;
    }
  }
}

void loop() {
// If statements that activates the system when it receives data from matlab
  if (Serial.available() > 0) {
    String incomingData = Serial.readStringUntil('\n');
    if (incomingData == "RESET") {
      wdt_enable(WDTO_15MS);
      while (1) {}
    }
    // Receives module formation in the form 'x,y'
    int commaIndex = incomingData.indexOf(',');
    if (commaIndex > -1) {
      String firstNumber = incomingData.substring(0, commaIndex);
      String secondNumber = incomingData.substring(commaIndex + 1);
      n = firstNumber.toInt() * secondNumber.toInt();
      Activate = true;
    }
  }

// Loop that reads all sensor values and prints them
  if (Activate) {
    for (int x = 0; x < MAX_DIMENSION; x++) {
      setPins(x, 2);
      for (int y = 0; y < MAX_DIMENSION; y++) {
        setPins(y, 5);
        for (int sensor = 0; sensor < n; sensor++) {
          double t = 0;
          for (int a = 0; a < avr; a++) {
            t += analogRead(A0 + sensor) * (Vi / 1023.0);
          }
          float Vo = t / avr;

          // If sensor is 'A' and it's not the first iteration, print a new line
          if (sensor == 0 && (x != 0 || y != 0)) {
            Serial.println();
          }

          // Print voltage readings with index
          Serial.print((char)('A' + sensor));
          Serial.print(x + 1);
          Serial.print(y + 1);
          Serial.print(Vo);
          Serial.print("");
        }
      }
    }
    Serial.println();  // Print a new line at the end of the loop
  }
}