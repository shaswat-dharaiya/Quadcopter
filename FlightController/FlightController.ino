/*
 * 31/10/2018
 * Author: Shaswat Dharaiya
 * Contact: shaswat.dharaiya@gmail.com
 * Code for Main Flight Controller.
*/

//With thrust adjustment
#include <Servo.h>  // For ESCs
#include <SoftwareSerial.h> // For HC-12
#include <SPI.h>
#include <Wire.h> // For MPU6050
#include "MPU.h";
#include <Adafruit_GFX.h> //For OLED
#include <Adafruit_SSD1306.h>
#include "SplitString.h";

//ESCs
Servo esc1;
Servo esc2;
Servo esc3;
Servo esc4;

int value;

SoftwareSerial drone(13, 12); // HC-12 TX Pin, HC-12 RX Pin
String outgoingString= "",incommingString = "1000:1000:1000:1000:;";
int setAT = 8,m;  //AT commands

//For MPU
//Create two float arrays in order to store data
float accel[3];
float gyro[3];

MPU mpuAccel(true);   //true wil activate Accelerometer.
MPU mpuGyro(false);   //false will activate Gyroscope.

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 32 // OLED display height, in pixels

// Declaration for an SSD1306 display connected to I2C (SDA, SCL pins)
#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

#define NUMFLAKES     10 // Number of snowflakes in the animation example

#define LOGO_HEIGHT   16
#define LOGO_WIDTH    16
static const unsigned char PROGMEM logo_bmp[] =
{ B00000000, B11000000,
  B00000001, B11000000,
  B00000001, B11000000,
  B00000011, B11100000,
  B11110011, B11100000,
  B11111110, B11111000,
  B01111110, B11111111,
  B00110011, B10011111,
  B00011111, B11111100,
  B00001101, B01110000,
  B00011011, B10100000,
  B00111111, B11100000,
  B00111111, B11110000,
  B01111100, B11110000,
  B01110000, B01110000,
  B00000000, B00110000 };

//Voltage
int analogInput1 = A1,analogInput2 = A0;
int value1 = 0,value2 = 0;
float vout[2] = {0.0, 0.0},vin[2] = {0.0, 0.0},R1 = 100000.0,R2 = 10000.0;

int inDelay = 10, outDelay = 13;

SplitString splitString;    //Rename the object as you wish.

void setup()
{

  Serial.begin(19200);

  esc1.attach(6, 1000, 2000);
  esc2.attach(9, 1000, 2000);
  esc3.attach(10, 1000, 2000);
  esc4.attach(11, 1000, 2000);

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

  Wire.begin();
  mpuAccel.startMPU();
  mpuGyro.startMPU();

   if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { // Address 0x3D for 128x64
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }
  delay(2000);
  display.clearDisplay();

  display.setTextSize(1.25);
  display.setTextColor(WHITE);
  // Display static text

  analogReference(DEFAULT);
  pinMode(analogInput1, INPUT);
  pinMode(analogInput2, INPUT);
}
void loop()
{
    incommingString = drone.readStringUntil(';');
    Serial.println(incommingString);
    int thrustValues[4];
    for(int i=0;i<4;i++)
      thrustValues[i] = splitString.stringToBeSplit(splitString.stringToBeSplit(incommingString,';',0),':',i).toInt();
    speedcontrol(thrustValues);
    delay(inDelay);

    mpuAccel.startReadMPU();
    mpuGyro.startReadMPU();
    mpuAccel.readMPU(accel);
    mpuGyro.readMPU(gyro);

    voltmeter();
    String thrustOut = thrustOnRotor();

    for(int i=0;i<3;i++){outgoingString += String(accel[i])+":";}
    for(int i=0;i<3;i++){outgoingString += String(gyro[i])+":";}
    outgoingString += "V";
    for(int i=0;i<2;i++){outgoingString += String(vin[i])+":";}
    outgoingString += "T"+thrustOut+";";

    drone.print(outgoingString);
    delay(outDelay);
    display.setCursor(45,0);
    display.println("V="+String(vin[0]));
    display.setCursor(90,0);
    display.println("v="+String(vin[1]));
    display.display();
}
void voltmeter()
{
  value1 = analogRead(analogInput1);
  vout[0] = (value1 * 5.0) / 1024;
  vin[0] = vout[0] / (R2 / (R1 + R2));
  if (vin[0] < 0.09)
  {
    vin[0] = 0.0;
  }
  value2 = analogRead(analogInput2);
  vout[1] = (value2 * 5.0) / 1024;
  vin[1] = vout[1] / (R2 / (R1 + R2));
  if (vin[1] < 0.09)
  {
    vin[1] = 0.0;
  }
}
void printvolt()  //Prints Voltage
{
  Serial.print(vin[0]);
  Serial.print("  ");
  Serial.println(vin[1]);
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
void speedcontrol(int thrust[4])  //Adjusts the orientation & thrust if there is current fluctuation
{
  for(int i=0;i<4;i++)
    thrust[i] = constrain(thrust[i],1000,2000);

  esc1.writeMicroseconds(thrust[0]);
  esc2.writeMicroseconds(thrust[1]);
  esc3.writeMicroseconds(thrust[2]);
  esc4.writeMicroseconds(thrust[3]);
}

String thrustOnRotor()
{
  int thrust[4];
  String outThrust ="";
  thrust[0] = esc1.readMicroseconds();
  thrust[1] = esc2.readMicroseconds();
  thrust[2] = esc3.readMicroseconds();
  thrust[3] = esc4.readMicroseconds();

  display.clearDisplay();
  for(int i=0;i<4;i++)
  {
    outThrust += String(thrust[i])+":";
      display.setCursor(0,i*8);
      display.println(thrust[i]);
  }
  return outThrust;
}
