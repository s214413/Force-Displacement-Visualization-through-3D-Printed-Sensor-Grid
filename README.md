# Force-Displacement-Visualization-through-3D-Printed-Sensor-Grid
This is a github repository which includes code and data files from the bachelor thesis 'Force Displacement Visualization through 3D Printed Sensor Grid'.
Authors: Peter Ebbe Jensen, Lukas Schou and Christian Cederhorn

The files in this repository is made up of Matlab, Arduino IDE and Maple files. 

Matlab files:
- 'Force_program' contains the code presenting sensorreadings in a three dimensional plot, fittet to display the values in Force.
- 'Voltage_program' contains the code presenting sensorreadings in a three dimensional plot in voltage.
- 'Test_single' is a test program used to read and plot voltage, force and resistance as a function of time

Arduino IDE files:
- '8x8_program' is the general code to read data from the modules which can be used together with both the 'Force_program' and 'Voltage_program' in Matlab.
- 'Test_single' is the Arduino code matching the 'Test_single' Matlab code, where you manually choose the location of the sensor to be read in the Arduino code.

Maple files:
