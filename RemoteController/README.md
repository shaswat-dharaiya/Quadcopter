# Quadcopter RC (Transmitter)

## Table of contents
* [General info](#general-info)
* [Technology](#technology)
* [Transmitter](#transmitter)
* [Initialization](#initialization)

## General info
This is Remote controller module for Quadcopter.

## Technology
Project is created with:
* C/C++
* Processing

## Transmitter
* Consists of:
  * ATMega328/MCU
  * Wireless module (HC-12 Transceiver module)
1. Initialization
  ```
  #include "Wire.h"
  #include <SoftwareSerial.h>
  ```
2. Initialize HC-12
  ```
  SoftwareSerial drone(10, 11); // HC-12 TX Pin, HC-12 rX Pin
  int setAT = 9;  //AT commands
  String incommingString = "",outgoingString= "1000:1000:1000:1000:;";
  ```
* In void setup():<br>
1. Setup baud rate for HC-12
  ```
  drone.begin(38400);  
  pinMode(setAT, OUTPUT);
  digitalWrite(setAT,LOW);
  delay(250);
  drone.print("AT+B38400");
  delay(250);
  drone.print("AT+C100");
  delay(250);
  drone.print("AT+RX");
  delay(250);
  digitalWrite(setAT,HIGH);
  drone.setTimeout(35);
  String out = "Starting Transmission";
  drone.print(out);
  ```
2. establishContact():<b>Establish Serial communication with RC interface.</b>
  ```
  void establishContact()
  {
    while (Serial.available() <= 0)
    {
      Serial.println("A");   // send a capital A
      delay(300);
    }
  }
  ```
* In void loop():<br>
1. Read incoming data serially from RC interface
  ```
  if (Serial.available() > 0)  // If data is available to read,
  {
    outgoingString = Serial.readStringUntil(';'); // read it and store it in val
    outgoingString += ";";
  }
  ```
2. Send the data to Quadcopter flight controller via HC-12
  ```
  drone.print(outgoingString);
  delay(outDelay);
  ```
2. Read and store incoming data from RC via HC-12
  ```
  incommingString = drone.readStringUntil(';');
  Serial.println(incommingString);    // Sending data to RC interface
  delay(inDelay);
  ```
