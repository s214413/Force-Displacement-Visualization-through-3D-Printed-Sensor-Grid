int Vi = 5;
int R = 88000; //Bias resistor
float Vs;
float t;
// Coordinates to single sensor
int x = 7; 
int y = 0;
float N;

// Averages pr. reading
#define avr 100

void setup() {
  Serial.begin(115200);
// Setup selector outputs
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
}

void loop() {
// Write selector outputs
  digitalWrite(4, (x & 0b001) ? HIGH : LOW);
  digitalWrite(3, (x & 0b010) ? HIGH : LOW);
  digitalWrite(2, (x & 0b100) ? HIGH : LOW);

  digitalWrite(7, (y & 0b001) ? HIGH : LOW);
  digitalWrite(6, (y & 0b010) ? HIGH : LOW);
  digitalWrite(5, (y & 0b100) ? HIGH : LOW);

// Voltage and Force readings
  float tVs = 0;
  float tN = 0;
  for (int a = 0; a < avr; a++) {
    Vs = analogRead(A0) * (5.0 / 1023.0);
    tVs = tVs + Vs;

// Force calculated based on the relation (20) from the loadcell
    N = analogRead(A5) * (5.0 / 1023.0) * 20;
    tN = tN + N;
  }
  Vs = tVs / avr;
  N = tN / avr;

// Calculate resistance
  float Rs = R * ((Vi / Vs) - 1);  // Subtract the initial reading and calculate the resistance

// Print readings
  Serial.print("R");
  Serial.print(Rs);
  Serial.print("F:");
  Serial.print(N);
  Serial.print("V:");
  Serial.println(Vs);

  delay(10);
}