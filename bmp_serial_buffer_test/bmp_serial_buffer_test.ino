#include <Audio.h>
#include <SPI.h>
#include <SSD_13XX.h>


// For the Adafruit shield, these are the default.
#define TFT_DC  9
#define TFT_CS 10
#define TFT_RS 8

uint8_t errorCode = 0;

SSD_13XX tft = SSD_13XX(TFT_CS, TFT_DC, TFT_RS);





// GUItool: begin automatically generated code
AudioInputUSB            usb1;           //xy=416,487
AudioMixer4              mixer1;         //xy=607,501
AudioOutputAnalog        dac1;           //xy=845,481
AudioConnection          patchCord1(usb1, 0, mixer1, 0);
AudioConnection          patchCord2(usb1, 1, mixer1, 1);
AudioConnection          patchCord3(mixer1, dac1);
// GUItool: end automatically generated code

byte anim;
byte boot = 1;
byte x,y,state,canWrite;
uint16_t c;
char buffer[12288]; //96x64x2 = 12288 bytes

void setup() {
Serial.begin(128000); // set maximum baudrate
 AudioMemory(20);
  tft.begin(false);

  //the following it's mainly for Teensy
  //it will help you to understand if you have choosed the
  //wrong combination of pins!
  errorCode = tft.getErrorCode();
  if (errorCode != 0) {
    Serial.print("Init error! ");
    if (bitRead(errorCode, 0)) Serial.print("MOSI or SCLK pin mismach!\n");
    if (bitRead(errorCode, 1)) Serial.print("CS or DC pin mismach!\n");
  }

mixer1.gain(0,0.5);
mixer1.gain(1,0.5);

while(!Serial);//don't continue until the serial port is open
}



void loop(void) {

if(Serial.available() > 0){//If we serial buffer
//read bytes to Serial and write them to the buffer
Serial.readBytes(buffer, 12288);

}

for(int b = 0; b < 12288; b+=2){//read Buffer
//read Pixel color ===>  buffer[first byte] | buffer[second byte] = word color(RGB565)
c = (buffer[b] << 8) | buffer[b+1];

tft.drawPixel(x,y,c); //write color  at coordinate x and y
x++;
if(x >= 96){//if coordinate x reached maximum width
  x = 0;
  y++;//increment y
  if(y >= 64){//if coordinate y reached maximum height
    y = 0;//back to 0
  }
}
}




}

