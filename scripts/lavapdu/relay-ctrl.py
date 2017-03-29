#!/usr/bin/python
# Controls a USB-connected Arduino to switch one of 4 relays for DC power control
# The Arduino is running code described here: http://playground.arduino.cc/Code/SerialControl
# The relay hardware is described here: http://www.seeedstudio.com/wiki/Relay_Shield_V2.0
# The Arduino code sometimes loses state after the serial connection is closed. 
# Not sure why. It may be a loading issue for the 5V USB supply.
# Not a big deal, since we just need to interrupt power for a reset. 
# Use the NC relay contacts for power connection, and NO contacts for reset-to-ground switching

import serial
import time
import sys

if len(sys.argv) < 3:
         print "Usage : relay-ctrl.py <relay_number> [HIGH | DUMMY_OP | LOW]"
         sys.exit()

if sys.argv[1] not in ("1","2","3","4"):
         print "Bad relay num"
         sys.exit()

if sys.argv[2] not in ("HIGH","DUMMY_OP","LOW"):
         print "Bad option"
         sys.exit()

str_pre = "00dw000"
str_high = "HIGH;\n"
str_low = " LOW;\n"

ser = serial.Serial(
         port='/dev/ttyACM0', 
         baudrate=9600,
         parity=serial.PARITY_NONE,
         stopbits=serial.STOPBITS_ONE,
         bytesize=serial.EIGHTBITS,
         timeout=0.5) 

print ser.read(size=32)
       
if sys.argv[2] == "HIGH":
         outstring = str_pre + str(int(sys.argv[1])+3) + str_high
         # empirically derived black magic, probably due to the 
         # non robust and single threaded serial library on the arduino
         ser.write(outstring) 
         ser.read(size=32)
         ser.write(outstring) 
         ser.read(size=32)
         ser.write(outstring) 
         ser.read(size=32)
elif sys.argv[2] == "LOW":
         outstring = str_pre + str(int(sys.argv[1])+3) + str_low
         # empirically derived black magic, probably due to the 
         # non robust and single threaded serial library on the arduino
         ser.write(outstring) 
         ser.read(size=32)
         ser.write(outstring) 
         ser.read(size=32)
         ser.write(outstring) 
         ser.read(size=32)
elif sys.argv[2] == "DUMMY_OP":
         print "Dummy Op"
else:
         print "Something's wrong"

time.sleep(1.75) 
# state will/may be reset
ser.close()



