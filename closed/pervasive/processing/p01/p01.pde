
import processing.serial.*;

PrintWriter output;
Serial myPort;  
float[] serialInArray = new float[6];
int inByte = -1;  
float meas1, meas2, meas3 = 0;
float kalx, kaly, kalz = 0;
int serialCount = 0;

void setup() {
 println(Serial.list());
 output = createWriter("accelerometer.csv");
 myPort = new Serial(this, Serial.list()[0], 9600);
}

void draw () {              
 while (myPort.available() > 0) {
   int serialByte = int(myPort.read());
   processByte(serialByte);
   output.println(map(meas1, 0, 255, 0, 1023) + "," + map(meas2, 0, 255, 0, 1023) + "," + map(meas3, 0, 255, 0, 1023));
 }
}
void keyPressed() {
 output.flush();
 output.close();
 exit();
}

void processByte( int inByte) {  
 serialInArray[serialCount] = inByte;
 serialCount++;
 if (serialCount > 2 ) {
   meas1 = serialInArray[0];
   meas2 = serialInArray[1];
   meas3 = serialInArray[2];
   serialCount = 0;
 }
}


