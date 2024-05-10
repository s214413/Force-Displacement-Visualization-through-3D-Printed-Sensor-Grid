# Force-Displacement-Visualization-through-3D-Printed-Sensor-Grid
This is a github repository which includes code and data files from the bachelor thesis 'Force Displacement Visualization through 3D Printed Sensor Grid'.
Authors: Peter Ebbe Jensen, Lukas Schou and Christian Cederhorn

The files in this repository is made up of Matlab, Arduino IDE, Maple files and a specs file to run the visualisation program.

Matlab files:
- 'Force_program.m' contains the code presenting sensorreadings in a three dimensional plot, fittet to display the values in Force.
- 'Resistor_model_3x3_full.mlx' code to calculate equations for 3 by 3 resistor model and then executing the solve.
- 'Resistor_model_3x3_with_equations.m' code to only execute the solve where the equation are already calculated.
- 'Resistor_model_8x8_full.mlx' code to calculate equations for 8 by 8 resistor model and then executing the solve.
- 'Test_single.m' is a test program used to read and plot voltage, force and resistance as a function of time.
- 'Voltage_program.m' contains the code presenting sensorreadings in a three dimensional plot in voltage.
- 'read_specs.m' is a file containing the function to read from the specification file.
- 'specs.txt' is the specification file.

Arduino IDE files:
- '8x8_program.ino' is the general code to read data from the modules which can be used together with both the 'Force_program' and 'Voltage_program' in Matlab.
- 'Motor_control.ino' is the Arduino code to run the motor for the tests.
- 'Test_single.ino' is the Arduino code matching the 'Test_single.m' Matlab code, where you manually choose the location of the sensor to be read in the Arduino code.

Maple files:
- 'Resistor_model_3x3.mw' is the maple dokument with the calculation to make and execute the 3 by 3 resistor model
- 'Resistor_model_3x3.pdf' is the pdf of the maple document "Resistor_model_3x3.mw"
- 'Uniform_pressure.mw' is the maple dokument with the equations and formula resistor models where resistors are exerted with uniform pressure 
- 'Uniform_pressure.pdf' is the pdf of the maple document "Uniform_pressure.mw"
