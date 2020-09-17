# Quadcopter
In this project I have assembled a drone using ATMega328 as the main processing unit on both, receiving and transmitting ends. The drone has a MPU6050 integrated with it(for orientation and balancing), and HC-12 module as Transreceiver.

## Table of contents
* [General info](#general-info)
* [Technology](#technology)
* [Features](#features)
* [Initialization](#initialization)
* [To-Do](#to-Do)
* [Quadcopter RC](#Quadcopter_RC)
* [Quadcopter flight controller](#Quadcopter_flight_controller)


## General info
* Quadcopter RC (Transmitter)
  * Consists of an ATMega328 connected to a computer. This can be replaced by Raspberry PI for portability. RC sends the thrust values for each motor.
* Quadcopter flight controller (Receiver)
  * Consists of an ATMega328 connected to an IMU (MPU6050), 4 ESCs (which is connected to the brushless motors).
  * Quadcopter consists of two batteries, a 12V Li-Po Battery (for brushless motors)& a normal 9V (for the onboard flight controller).<br>
  * There is an onboard OLED screen present for debugging & testing.
* Communication
  * Both sides communicate using HC-12 Transreceiver module, at a baud rate of 38400.

## Technology
Project is created with:
* ATMega328
* Processing
* HC-12 Transreceiver module
* MPU6050
* ESC (30A)
* OLED

## Features
* Advance Quadcopter Maneuverability
* Wireless communication

## To-Do
* Move forward
* Move reverse
* Move left
* Move right
* Stay/Stop Motion.

## Quadcopter RC
* Consists of:
  * ATMega328/MCU
  * Wireless module (HC-12 Transreceiver module)
  * Connected serially to the RC interface.

## Quadcopter flight controller
* Consists of:
  * ATMega328/MCU
  * MPU6050
  * OLED
  * ESC (30A)
  * Wireless module (HC-12 Transreceiver module)
