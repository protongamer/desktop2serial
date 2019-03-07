  import processing.serial.*;
import processing.video.*;
import java.awt.Robot;
import java.awt.Rectangle;
import java.awt.AWTException;

Serial myPort;


int offsetX = 110;
int offsetY = 10;
 
PImage screenshot;




int px=0,py=0; //pixel width height

byte buffer[] = new byte[12288]; //video buffer



void setup() {
  
  size(320, 240);

// List all the available serial ports:
printArray(Serial.list());

// Open the port you are using at the rate you want:
myPort = new Serial(this, Serial.list()[0], 128000);

String s = "Com port : " + Serial.list()[0];
fill(50);
text(s, 110, 120);  // Text wraps within text box
}



void draw() {
  
screenshot();//capture desktop
  
image(screenshot, offsetX, offsetY, 96, 64);//show desktop at size 96x64

fillBuffer();//get pixels color and write them to the buffer 

myPort.write(buffer);//send the buffer
fill(50);
rect(110,150,96,64);
fill(255);
textSize(32);
text("Exit", 130, 195);  // Text wraps within text box
if(mouseX >= 110 && mouseX <= 206 && mouseY >= 150 && mouseY <= 214){

  if(mousePressed == true){//if we press to exit button
   exit(); 
  }
  
}

}



int map_int(int x, int in_min, int in_max, int out_min, int out_max) {//map function for int
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}




void fillBuffer(){
  byte k = 0;
  for(int j = 0; j < 64; j++){
    for(int i = 0; i < 192; i+=2){
 
  buffer[(192*j)+i] = convert1(k,j);
 
  if(i < 191){
  buffer[(192*j)+i+1] = convert2(k,j);
}
  k++;//each word calculated(buffer[first byte] and buffer[second byte] increment k to get the next pixel
    }
k = 0;//once the line is write to the buffer, get the next line and put k to 0 to start at the first pixel of the new line
  }
  
}



byte convert1(int x1, int y1){//calculate first byte of the word
  
  int b1;
  
  b1 = cc(x1,y1);
  b1 = b1 >> 8;

  return (byte)b1;
}



byte convert2(int x2, int y2){//calculate second byte of the word
 
  int b2;
  
  b2 = cc(x2,y2);
  b2 = b2 & 0xFF;
  
  return (byte)b2;
}



int cc(int x, int y){

  long c = get(offsetX + x, offsetY + y); //get pixel color RGB888
  long r = (c & 0xFF0000) >> 16; //get Red byte with mask
  long g = (c & 0xFF00) >> 8;    //get Green byte with mask
  long b = (c & 0xFF);           //get Blue byte with mask
  
  //convert RGB888 values to RGB565 values
  r = map_int((int)r,0,255,0,31);
  g = map_int((int)g,0,255,0,63);
  b = map_int((int)b,0,255,0,31);
  
  //Bitwise to have a word color(RGB565)
  c = r << 6;
  c |= g;
  c = c << 5;
  c |= b;

  
  return (int)c;
}


void screenshot() {
  try {
    Robot robot = new Robot();
    screenshot = new PImage(robot.createScreenCapture(new Rectangle(0, 0, displayWidth, displayHeight)));
  } 
  catch (AWTException e) {
  }
}
