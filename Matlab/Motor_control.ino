/*
The program works by entering a command in the serial monitor.

To make sure the motor wont run down further than the setup allow a limit is set up. The limit by defualt is set to "bottom_limit" which is the
distance from the top to the bottom of the setup. The limit change depending on what need to be tested. The variable "sensor_bottom" is subtracted 
from the limit, and is the height of the thing being tested that shall not be pressed down.

For the limit to work, the motor will have to be put to the top and the distance set to 0. 

List of commands:
  - Move motor up and down (distance in mm)
  Positive number moves motor down (ex. type "10" for 10mm)
  Negative number moves motor up (ex. type "-5" for 5mm)

  - Change the speed of the motor (speed in rpm)
  type "rpm" and then the speed (ex. "rpm60" to change speed to 60 rpm)

  - Repeat motor move up and down for a number of cycles
  type "cycle" and then the distance in mm, then "," and then the number of cycles
  Example: cycle10,5 moves the motor 10mm down, then 10mm up, and repeats 5 times.

  - Manually set the distance to the top (distance in mm)
  type "top" and then the distance between the motor and the top (ex. "top0" to change the distance to 0mm)
*/

#include <Arduino.h>
#include "BasicStepperDriver.h"

#define MOTOR_STEPS 25000
#define RPM 30
#define MICROSTEPS 1

// The motor moves 5mm per revolution
#define mm_pr_rev 5

// Pinout for the motor
#define DIR 8
#define STEP 9

// 2-wire basic config, microstepping is hardwired on the driver
BasicStepperDriver stepper(MOTOR_STEPS, DIR, STEP);



#define bottom_limit 177.25   // distance from top to bottom



// change this to the height of your sensor
#define sensor_bottom 1.6   // Height of sensor that shall not be pressed down (this will be subtracted from the bottom_limit)



String incomingData;
float move = 0;
float dist = 0;   // distance from top
int new_rpm;

void setup() {
  stepper.begin(RPM, MICROSTEPS);
  Serial.begin(115200);
}

void moveMotorCycles(float distance, int cycles) {
  for (int i = 0; i < cycles; i++) {
    // Move motor down
    if (dist + distance - sensor_bottom <= bottom_limit) {
      stepper.rotate(360 / mm_pr_rev * distance);
      dist = dist + distance;
      Serial.println(dist);
      Serial.print("The motor has now moved down: ");
      Serial.print(distance);
      Serial.println("mm");
    } else {
      Serial.println("Limit reached");
    }
    
    // Move motor up
    if (dist - distance >= 0) {
      stepper.rotate(-360 / mm_pr_rev * distance);
      dist = dist - distance;
      Serial.println(dist);
      Serial.print("The motor has now moved up: ");
      Serial.print(distance);
      Serial.println("mm");
    } else {
      Serial.println("Top limit reached");
    }
  }
}

void loop() { 
  if (Serial.available() > 0) {
    // Read incoming message
    incomingData = Serial.readStringUntil('\n');
    String dat = incomingData;

    // Change the rpm of the motor
    if (dat.substring(0, 3) == "rpm") {
      dat.remove(0, 3);
      new_rpm = dat.toFloat();
      stepper.begin(new_rpm, MICROSTEPS);
      delay(1000);
      Serial.print("rpm has been changed to: ");
      Serial.println(new_rpm);

      //  Manually change the distance to the top
    } else if (dat.substring(0, 3) == "top"){
      dat.remove(0, 3);
      dist = dat.toFloat();
      
      // Runs the motor down and up for a number of cycles
    } else if (dat.substring(0, 5) == "cycle") {
      dat.remove(0, 5);
      int separatorIndex = dat.indexOf(",");
      float distance = dat.substring(0, separatorIndex).toFloat();
      int cycles = dat.substring(separatorIndex + 1).toInt();
      moveMotorCycles(distance, cycles);
    } else {
      move = dat.toFloat();
    }
  }

  // Moves the motor up or down corresponding to the move
  if (move != 0) {
    if (dist + move - sensor_bottom > bottom_limit) {
      Serial.println("Limit reached");
      move = 0;
    } else{
      stepper.rotate(360 / mm_pr_rev * move);
      dist = dist + move;
      Serial.println(dist);
      Serial.print("The motor has now moved: ");
      Serial.print(move);
      Serial.println("mm");
      move = 0;
    }
  }

  delay(100);
}
