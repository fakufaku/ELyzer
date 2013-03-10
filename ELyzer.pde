  /**
 * Get Line In
 * by Damien Di Fede.
 *  
 * This sketch demonstrates how to use the <code>getLineIn</code> method of 
 * <code>Minim</code>. This method returns an <code>AudioInput</code> object. 
 * An <code>AudioInput</code> represents a connection to the computer's current 
 * record source (usually the line-in) and is used to monitor audio coming 
 * from an external source. There are five versions of <code>getLineIn</code>:
 * <pre>
 * getLineIn()
 * getLineIn(int type) 
 * getLineIn(int type, int bufferSize) 
 * getLineIn(int type, int bufferSize, float sampleRate) 
 * getLineIn(int type, int bufferSize, float sampleRate, int bitDepth)  
 * </pre>
 * The value you can use for <code>type</code> is either <code>Minim.MONO</code> 
 * or <code>Minim.STEREO</code>. <code>bufferSize</code> specifies how large 
 * you want the sample buffer to be, <code>sampleRate</code> specifies the 
 * sample rate you want to monitor at, and <code>bitDepth</code> specifies what 
 * bit depth you want to monitor at. <code>type</code> defaults to <code>Minim.STEREO</code>,
 * <code>bufferSize</code> defaults to 1024, <code>sampleRate</code> defaults to 
 * 44100, and <code>bitDepth</code> defaults to 16. If an <code>AudioInput</code> 
 * cannot be created with the properties you request, <code>Minim</code> will report 
 * an error and return <code>null</code>.
 * 
 * When you run your sketch as an applet you will need to sign it in order to get an input. 
 * 
 * Before you exit your sketch make sure you call the <code>close</code> method 
 * of any <code>AudioInput</code>'s you have received from <code>getLineIn</code>.
 */

import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*;
import cc.arduino.*;

Minim minim;
AudioInput in;
FFT fft;
Arduino arduino;
String windowName;

void setup()
{
  size(512, 200);

  minim = new Minim(this);
  minim.debugOn();
  
  // get a line in from Minim, default bit depth is 16
  //in = minim.getLineIn(Minim.STEREO, 1024);
  in = minim.getLineIn();
  
  // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
  // note that this needs to be a power of two and that it means the size of the spectrum
  // will be 512. see the online tutorial for more info.
  fft = new FFT(in.bufferSize(), in.sampleRate());
  
  // create the arduino object to control the EL wire
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  for (int i = 4 ; i < 8 ; i++)
    arduino.pinMode(i, Arduino.OUTPUT);
  
  textFont(createFont("SanSerif", 12));
  windowName = "None";
}

void draw()
{
  background(0);
  stroke(255);
  
  setEL();
  
  // perform a forward FFT on the samples in jingle's left buffer
  // note that if jingle were a MONO file, this would be the same as using jingle.right or jingle.left
  fft.forward(in.mix);
  for(int i = 0; i < fft.specSize(); i++)
  {
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
    line(i, height, i, height - (fft.getBand(i)*4));
  }
  fill(255);
  // keep us informed about the window being used
  text("The window being used is: " + windowName, 5, 20);
}

void keyReleased()
{
  if ( key == 'w' ) 
  {
    // a Hamming window can be used to shape the sample buffer that is passed to the FFT
    // this can reduce the amount of noise in the spectrum
    fft.window(FFT.HAMMING);
    windowName = "Hamming";
  }
  
  if ( key == 'e' ) 
  {
    fft.window(FFT.NONE);
    windowName = "None";
  }
}

void stop()
{
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();
  
  super.stop();
}

void setEL()
{
  int[] bands = new int[4];
  int[] bl = {0, 50, 150, 256, 512};
  int[] ths = {5, 3, 1, 0};
  
  for (int i = 0 ; i < 4 ; i++)
  {
    bands[i] = 0;
    for (int j = bl[i] ; j < bl[i+1] ; j++)
      bands[i] += fft.getBand(j);
    bands[i] /= (bl[i+1] - bl[i]);
    if (bands[i] > ths[i])
      arduino.digitalWrite(4+i, Arduino.HIGH);
    else
      arduino.digitalWrite(4+i, Arduino.LOW);
  }
}

