/*
 * 31/10/2019
 * Author: Shaswat Dharaiya
 * Contact: shaswat.dharaiya@gmail.com
 * Code for Main Remote Controller.
 * Works in Parellal with the code in Processing 
*/
#include "Wire.h" // For I2C
#include <SoftwareSerial.h>
SoftwareSerial drone(10, 11); // HC-12 TX Pin, HC-12 rX Pin

//ignore
int setAT = 9,m;  //AT commands

String incommingString = "",outgoingString= "1000:1000:1000:1000:;";

int inDelay = 10, outDelay = 13;

void setup() 
{
  Serial.begin(19200);
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
  establishContact();  // send a byte to establish contact until receiver responds 
}

void loop() 
{
  if (Serial.available() > 0)  // If data is available to read,
  {
    outgoingString = Serial.readStringUntil(';'); // read it and store it in val
    outgoingString += ";";
  }
  drone.print(outgoingString);
  delay(outDelay);
  
  incommingString = drone.readStringUntil(';');
  Serial.println(incommingString);    // Sending data to RC interface
  delay(inDelay);
}

void establishContact() 
{
  while (Serial.available() <= 0) 
  {
    Serial.println("A");   // send a capital A
    delay(300);
  }
}

void printmov()  //Ignore
{
  Serial.print(m);
  Serial.print("  ");
  switch(m)
  {
    case 1: Serial.println("1+"); //     1ST QUAD + means cw
            break;
    case 2:Serial.println("1-");  // 1ST QUAD - means ccw
            break;
    case 3:Serial.println("1 No yaw"); // 1ST QUAD No yaw
            break;
    case 4:Serial.println("2+");// 2ND QUAD + means cw
            break;
    case 5:Serial.println("2-");// 2ND QUAD - means ccw
            break;
    case 6:Serial.println("2 No yaw");  // 2ND QUAD No yaw
            break;
    case 7:Serial.println("3+");// 3RD QUAD + means cw
            break;
    case 8:Serial.println("3-");// 3RD QUAD - means cw
            break;
    case 9:Serial.println("3 No yaw");  // No yaw
            break;
    case 10:Serial.println("4+");// 4TH QUAD + means cw
            break;
    case 11:Serial.println("4-");// 4TH QUAD - means ccw
            break;
    case 12:Serial.println("4 No yaw");  // 4TH QUAD No yaw
            break;
    default:Serial.println("Unknown Error");
            break;     
  }
}
