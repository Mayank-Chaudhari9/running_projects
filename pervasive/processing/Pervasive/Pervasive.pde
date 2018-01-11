//  Nadi Pariksha


import org.jtransforms.fft.FloatFFT_1D;
import processing.serial.*;



boolean debug = false;

Serial myPort; 
String comPort = "/dev/ttyACM0";
int LabelSize = 24;


// FFT spectrum variables
float[] spectrumArr;       // PSD spectral data
float rrData[]= new float[20]; // this defines the max number of data elements (beats) to evaluate via FFT
String rrDataStr = "";
String[] PSDlabels; // the labels are dynamically generated by FFT process

// per beat holders
int beatCount = 0;
float LF = 0; // Low Frequency (  <= .15 Hz )
float HF = 0; // High Frequency (  >  .15 Hz)
float LFold = 0;
float HFold = 0;
// total accumulators for averages
//float LFa = 0;
//float HFa = 0;
boolean firstTime = true;
color LFcolor = color(200, 255, 8);
color HFcolor = color(255, 0, 255);

// The fixated upper and lower bounds for deciding High and Low frequence (need to be fixed based on device redings
// LF = .04 - .15Hz
// HF = .15 - .4Hz

int BPM = 20; // seeded so the graph starts nice
int IBI = 200; // inter beat interval in millis


// main waveform graph variables

int xPos = 1;         // horizontal position of the graph
int xPosOld = 1; // holder
float inByte = 0;
float sensorValOld = 0;

// frequency and other main variables and holders
float freq = 0;
float freqMappedVal = 0;
float runningTotal = 1;   // can't initialize as 0 because of math
float mean;               // useful for VLF derivation...........
int P;                    // peak value of IBI waveform
int T;                    // trough value of IBI waveform
int amp=0; 
int lastIBI; 
float[] powerPointX;      // array of power spectrum power points
float[] powerPointY;
int pointCount = 0;       // used to help fill the powerPoint arrays
int[] PPG;                // array of raw Pulse Sensor datapoints
String direction = "none";
int maxDots = 500;  // after this number of beats the oldest dots begin to disappear
boolean goingUp;


int yMod = 0; // adjust to center the graph up or down reversed: -10 (up 10) and 10 (down 10)
float magnify = 1.6; // magnification of main waveform graph
int LFHFmagnify = 1; // increase the x axis speed for LF vs HF power graph

int WaveWindowX = 260; // start xposition of main waveform window

int BPMWindowWidth = 150;
int BPMWindowHeight = 200;
int BPMWindowY = 35;
int BPMxPos = 36;

int IBIWindowWidth = 150;
int IBIWindowHeight = 200;
int IBIWindowY = 235;
int IBIxPos = 236;

int FreqWindowWidth = 200;
int FreqWindowHeight = 200;
int FreqWindowY = 435;
int FreqxPos = 436;
int FreqMaxVal = 1000;

int PSDWindowWidth = 230;
int PSDWindowHeight = 200;
int PSDWindowY = 685;
int PSDxPos = 686;

int HLWindowWidth = 210;
int HLWindowHeight = 200;
int HLWindowY = 965;
int HLxPos = 965;

int DataWindowWidth = 160;
int DataWindowHeight = 230;
int DataWindowY = 1210;
int DataxPos = 1211;

int HLSessionWindowWidth = 160;
int HLSessionWindowHeight = 100;
int HLSessionWindowY = 1210;
int HLSessionxPos = 1211;

boolean flatLine = false;
boolean pulseData = false;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          Setup ()                                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void setup() {

  //surface.setResizable(false); // don't allow window to be resized

  size(1390, 760);
  myPort = new Serial(this, comPort, 115200);
  //wait for a new line char to come from the arduino newline character:
  myPort.bufferUntil('\n');

  PPG = new int[maxDots];                // PPG array that that prints heartbeat waveform
  for (int i=0; i<=PPG.length-1; i++) {
    PPG[i] = FreqWindowHeight/2;             // initialize PPG widow with data line at midpoint
  }

  powerPointX = new float[maxDots];    // these arrays hold the power spectrum point coordinates
  powerPointY = new float[maxDots];

  for (int i=0; i<maxDots; i++) {       // startup values out of view
    powerPointX[i] = -10;
    powerPointY[i] = -10;
  }


  background(255);
  strokeWeight(4.0); // nice and thick for the main window
  // draw main lower waveform window and other graph windows
  rect(1, WaveWindowX, width-3, height-WaveWindowX-2, 5); 
  strokeWeight(1.8);
  fill(0);
  rect(BPMWindowY-1, 30, BPMWindowWidth+1, BPMWindowHeight+1, 5); // bpm window
  rect(IBIWindowY-1, 30, IBIWindowWidth+1, IBIWindowHeight+1, 5); //  IBI  window
  rect(FreqWindowY-1, 30, FreqWindowWidth+1, FreqWindowHeight+1, 5); //  frequency  window
  rect(PSDWindowY-1, 30, PSDWindowWidth+1, PSDWindowHeight+1, 5); //  PSD  window
  rect(HLWindowY-1, 30, HLWindowWidth+1, HLWindowHeight+1, 5); //  HL  window
  rect(HLSessionWindowY-1, 30, HLSessionWindowWidth+1, HLSessionWindowHeight+1, 5); //  HLSession  window



  // draw BPM scale
  text("0", BPMWindowY+1, WaveWindowX-15);
  text(BPMWindowWidth/2, BPMWindowY+ (BPMWindowWidth/2) - 15, WaveWindowX-15);
  text(BPMWindowWidth, BPMWindowY+ BPMWindowWidth - 15, WaveWindowX-15);
  text("20-", BPMWindowY-17, BPMWindowHeight+33);
  text("40-", BPMWindowY-17, BPMWindowHeight+33-20);
  text("60-", BPMWindowY-17, BPMWindowHeight+33-40);
  text("80-", BPMWindowY-17, BPMWindowHeight+33-60);
  text("100-", BPMWindowY-23, BPMWindowHeight+33-80);
  text("120-", BPMWindowY-23, BPMWindowHeight+33-100);
  text("140-", BPMWindowY-23, BPMWindowHeight+33-120);
  text("160-", BPMWindowY-23, BPMWindowHeight+33-140);
  text("180-", BPMWindowY-23, BPMWindowHeight+33-160);
  text("200-", BPMWindowY-23, BPMWindowHeight+33-180);
  text("220-", BPMWindowY-23, BPMWindowHeight+33-200);


  // draw LF/HF scale and color boxes
  fill(LFcolor);
  stroke(0);
  rect(HLWindowY+70, WaveWindowX-25, 10, 10, 1);
  fill(HFcolor);
  rect(HLWindowY+140, WaveWindowX-25, 10, 10, 1);
  textSize(10);
  fill(0);
  text("LF", HLWindowY+50, WaveWindowX-15);
  text("HF", HLWindowY+120, WaveWindowX-15);

  // draw LF/HF session avg scale and color boxes
  fill(LFcolor);
  stroke(0);
  rect(HLSessionWindowY+40, WaveWindowX-25, 10, 10, 1);
  fill(HFcolor);
  rect(HLSessionWindowY+120, WaveWindowX-25, 10, 10, 1);
  textSize(10);
  fill(0);
  text("LF", HLSessionWindowY+20, WaveWindowX-15);
  text("HF", HLSessionWindowY+100, WaveWindowX-15);

  // draw IBI scale
  text("0", IBIWindowY+1, WaveWindowX-15);
  text(IBIWindowWidth/2, IBIWindowY+ (IBIWindowWidth/2) - 15, WaveWindowX-15);
  text(IBIWindowWidth, IBIWindowY+ IBIWindowWidth - 15, WaveWindowX-15);
  text("200-", IBIWindowY-25, IBIWindowHeight+33);
  text("400-", IBIWindowY-25, IBIWindowHeight+33-20);
  text("600-", IBIWindowY-25, IBIWindowHeight+33-40);
  text("800-", IBIWindowY-25, IBIWindowHeight+33-60);
  text("1000-", IBIWindowY-30, IBIWindowHeight+33-80);
  text("1200-", IBIWindowY-30, IBIWindowHeight+33-100);
  text("1400-", IBIWindowY-30, IBIWindowHeight+33-120);
  text("1600-", IBIWindowY-30, IBIWindowHeight+33-140);
  text("1800-", IBIWindowY-30, IBIWindowHeight+33-160);
  text("2000-", IBIWindowY-30, IBIWindowHeight+33-180);
  text("2200-", IBIWindowY-30, IBIWindowHeight+33-200);

  ///// draw frequency scale labels
  text("0", FreqWindowY, WaveWindowX-15);
  text("1", FreqWindowY + (FreqWindowWidth/2)-5, WaveWindowX-15);
  text(".5", FreqWindowY + (FreqWindowWidth/4)-7, WaveWindowX-15);
  text("1.5", FreqWindowY + (FreqWindowWidth/2) + (FreqWindowWidth/4)-10, WaveWindowX-15);
  text("2", FreqWindowY + (FreqWindowWidth)-5, WaveWindowX-15);
  //
  text("000-", FreqWindowY-25, FreqWindowHeight+33);
  text("100-", FreqWindowY-25, FreqWindowHeight+33-20);
  text("200-", FreqWindowY-25, FreqWindowHeight+33-40);
  text("300-", FreqWindowY-25, FreqWindowHeight+33-60);
  text("400-", FreqWindowY-25, FreqWindowHeight+33-80);
  text("500-", FreqWindowY-25, FreqWindowHeight+33-100);
  text("600-", FreqWindowY-25, FreqWindowHeight+33-120);
  text("700-", FreqWindowY-25, FreqWindowHeight+33-140);
  text("800-", FreqWindowY-25, FreqWindowHeight+33-160);
  text("900-", FreqWindowY-25, FreqWindowHeight+33-180);
  text("1000-", FreqWindowY-30, FreqWindowHeight+33-200);

  // PSD vertical scale
  text("000-", PSDWindowY-25, PSDWindowHeight+30);
  text("500-", PSDWindowY-25, PSDWindowHeight+30-25);
  text("1000-", PSDWindowY-30, PSDWindowHeight+30-50);
  text("1500-", PSDWindowY-30, PSDWindowHeight+30-75);
  text("2000-", PSDWindowY-30, PSDWindowHeight+30-100);
  text("2500-", PSDWindowY-30, PSDWindowHeight+30-125);
  text("3000-", PSDWindowY-30, PSDWindowHeight+30-150);
  text("3500-", PSDWindowY-30, PSDWindowHeight+30-175);
  text("4000-", PSDWindowY-30, PSDWindowHeight+30-200);

  // LF vs HF vertical scale
  text("000-", HLWindowY-25, HLWindowHeight+34);
  text("1500-", HLWindowY-30, HLWindowHeight+34-50);
  text("1000-", HLWindowY-30, HLWindowHeight+34-100);
  text("1500-", HLWindowY-30, HLWindowHeight+34-150);
  text("2000-", HLWindowY-30, HLWindowHeight+34-200);
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                    Draw ()                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

void draw() {


  strokeWeight(1.8); // reset strokeWeight

  // determine if values indicate no pulse flat line
  if (inByte > 800)
  {
    flatLine = true;
  }

  if (inByte <= 0)
  {
    flatLine = false;
  }
  if ( (inByte - sensorValOld) > 600 )  //if the HRV variation between IBI is greater than 600ms
    flatLine = true;

  if (flatLine)
    inByte = 360;


  // draw main waveform line
  if (debug)
  {
    print("xPos: " + xPos); 
    println(" xPosOld: " +xPosOld);

    print("sensor: " +inByte); 
    println("sensorOld: " +sensorValOld);
  }

  float yOld; 
  float yNew; 

  if (xPosOld != xPos)
  {
    yOld = (height-sensorValOld)*magnify;
    yNew = (height-inByte)*magnify;

    // keep peaks from going over the top of window area
    if (yOld < WaveWindowX)
      yOld = WaveWindowX;
    if (yNew < WaveWindowX)
      yNew = WaveWindowX;

    line(xPos*magnify, yOld, (xPos+1)*magnify, yNew); // left to right
    if (debug)
    {
      println("--------------------------------------- main graph line print  -------------------- " + xPos);
    }
    xPosOld = xPos;
    sensorValOld = inByte;
  }


  // clear labels
  fill(255);
  rect(BPMWindowY, 0, BPMWindowWidth, 30, 5); // clear BPM label data
  rect(IBIWindowY, 0, IBIWindowWidth, 30, 5); // clear IBI label data
  rect(FreqWindowY, 0, FreqWindowWidth, 30, 5); // clear Frequency label  data
  rect(PSDWindowY, 0, PSDWindowWidth, 30, 5); // clear PSD title label data
  rect(HLWindowY, 0, HLWindowWidth, 30, 5); // clear HL title label data
  //rect(DataWindowY, 0, DataWindowWidth, 30, 5); // clear HL title label data

  /////////////////////       IBI graph   ///////////////////////
  // IBI = 4000; // used to test scale accuracy
  //  float mIBI = map(IBI, 100, 2000, 50, IBIWindowHeight-10);
  float tempIBI = IBI-200;
  float mIBI = map(tempIBI, 0, 2000, 0, IBIWindowHeight);

  stroke(0, 255, 0);
  line(IBIxPos, 229, IBIxPos, 230-mIBI); // left to right
  if (IBIxPos == IBIWindowWidth+IBIWindowY) // reset IBI at window end
  {
    stroke(0);
    fill(0);
    rect(IBIWindowY-1, 30, IBIWindowWidth+1, IBIWindowHeight+1, 5); //  IBI  window
    IBIxPos = IBIWindowY+1;
  }

  ////////////////////////      BPM graph      //////////////////////////////
  stroke(255, 0, 0);
  // BPM = 120; // used to test scale positions
  int BPMtemp = BPM-20;
  //BPMtemp = 200;
  if (BPMtemp > 220) // keeps line from drawing into title box
    BPMtemp = 220;  

  line(BPMxPos, 229, BPMxPos, 230-BPMtemp); // left to right+1;
  if (BPMxPos == BPMWindowWidth+BPMWindowY) // reset BPM at window end
  {
    stroke(0);
    fill(0);
    rect(BPMWindowY-1, 30, BPMWindowWidth+1, BPMWindowHeight+1, 5); // bpm window
    BPMxPos = BPMWindowY+1;
  }
  //reset
  stroke(0);
  fill(0);

  textSize(LabelSize);
  text("BPM: "+ BPM, BPMWindowY + 10, 0, width, height);
  text("IBI: " + IBI, IBIWindowY + 10, 0, width, height);
  text("LF vs HF Power", HLWindowY + 20, 0, width, height);

  if (freq > 2) // don't let he dot plot go out of graph bounds
    freq = 0;

  String F = nf(freq, 1, 3);  // format the freq variable for printing

  text("Hz: " + F, FreqWindowY+10, 0, width, height);
  fill(255);

  // draw Beat Counter window
  rect(DataWindowY, 0, DataWindowWidth, DataWindowHeight, 5);
  rect(DataWindowY, 0, DataWindowWidth, 30, 5);
  fill(0);
  text("Beats: " + beatCount, DataWindowY+10, 0, width, height);

  float hPercent = 100;
  float lPercent = 100;
  String lf = ""; 
  String hf = "";

  if (LF > 0 && HF > 0)
  {
    lf = nf((float)(LF), 1, 1);
    hf = nf((float)(HF), 1, 1);

    hPercent = 100-(HF/(HF+LF)*100);
    lPercent = 100-(LF/(HF+LF)*100);
  }


  //   draw out session averages for HF and LF
  fill(255);
  rect(HLSessionWindowY-1, 100, HLSessionWindowWidth+1, HLSessionWindowHeight+30, 5); //  HLSession  window
  fill(0);
  textSize(13);
  text("LF vs HF Percentage ", DataWindowY+15, 105, width, height);
  fill(LFcolor);
  rect(HLSessionWindowY-1, 130 + lPercent, HLSessionWindowWidth/2, HLSessionWindowHeight - lPercent, 5); //  HLSession  window
  fill(HFcolor);
  rect(HLSessionWindowY+(HLSessionWindowWidth/2), 130 + hPercent, HLSessionWindowWidth/2, HLSessionWindowHeight- hPercent, 5); //  HLSession  window

  fill(0);
  textSize(14);
  text("(LF <= .15) = " + lf, DataWindowY+5, 40, width, height);
  text("(HF  >  .15) = " + hf, DataWindowY+5, 70, width, height);

  textSize(12);
  text("%" + nf(100-lPercent, 1, 1), HLSessionWindowY+20, 125 + lPercent, HLSessionWindowWidth/2);
  text("%" + nf(100-hPercent, 1, 1), HLSessionWindowY+(HLSessionWindowWidth/2)+20, 125 + hPercent, HLSessionWindowWidth/2);

  if (beatCount < 10)
  {
    rect(HLWindowY-1, 30, HLWindowWidth+1, HLWindowHeight+1, 5); 
    fill(255, 0, 0);
    textSize(14);
    text("Gathering Data", HLxPos+40, 60);
    text(10-beatCount, HLxPos+82, 80);
  } else
  {
    if (firstTime)
      rect(HLWindowY-1, 30, HLWindowWidth+1, HLWindowHeight+1, 5);
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////               draw LF vs HF chart      /////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////
  // LF = 1000; // used to test scaling
  //HF = 1500; // // used to test scaling
  float mappedLF = 230 - map((float)LF, 0, 2000, 0, 200);
  float mappedLFold= 230 - map((float)LFold, 0, 2000, 0, 200);

  float mappedHF = 230 - map((float)HF, 0, 2000, 0, 200);
  float mappedHFold = 230 - map((float)HFold, 0, 2000, 0, 200);

  if (pulseData)
  {

    stroke(LFcolor);
    strokeWeight(1.1);
    line(HLxPos-LFHFmagnify, mappedLFold, (HLxPos+1), mappedLF); // left to right LF line graph

    stroke(HFcolor);
    line(HLxPos-LFHFmagnify, mappedHFold, (HLxPos+1), mappedHF); // left to right HF line graph
  }

  fill(0);
  stroke(0);

  if (HLxPos >= (HLWindowWidth+HLWindowY)-1) // reset HL at window end
  {
    stroke(0);
    fill(0);
    rect(HLWindowY-1, 30, HLWindowWidth+1, HLWindowHeight+1, 5); // HL window clear
    HLxPos = HLWindowY+1;
  }


  ////////////////////////////// draw the Freq plot graph ////////////////////////////////
  //amp = 1300; // used to test scale accuracy
  float mappedAmp = map(amp, 0, FreqMaxVal, 200, 0);

  //  float mappedAmp = map(amp, 0, 1000, 200, 0);
  //freq = 1.50; // used to test positions on graph for accurate scaling
  if (freq >= 0 && mappedAmp < FreqMaxVal )
  {

    rect(FreqWindowY, 30, FreqWindowWidth, FreqWindowHeight, 5); // draw freq graph window

    // draw bar
    freqMappedVal = map(freq, 0, 2, FreqWindowY, FreqWindowWidth+FreqWindowY);
    freqMappedVal =  constrain(freqMappedVal, FreqWindowY, FreqWindowWidth+FreqWindowY); 

    stroke(200, 255, 0);

    // draw dots
    for (int i=0; i<maxDots; i++) {
      if (powerPointY[i] > 0 && powerPointX[i] < FreqWindowWidth+FreqWindowY) // only draw  dots in the window
        ellipse(powerPointX[i], powerPointY[i]+30, 1, 1);    // plot a history of data points in red
    }

    stroke(250, 5, 180); 
    strokeWeight(3);
    line(freqMappedVal, FreqWindowHeight+30-1, freqMappedVal, mappedAmp+30  );

    fill(255, 0, 0);  
    textSize(12);
    // draw amps above bar
    if (mappedAmp > 5 && 1.9 >freq && freq >0) // don't go out of window bounds
      text(amp, freqMappedVal-10, mappedAmp+25);
  }


  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                         draw PSD graph                                            //
  ///////////////////////////////////////////////////////////////////////////////////////////////////////

  // reset
  fill(0);
  stroke(0);
  textSize(LabelSize);
  text("IBI Spectrum (PSD)", PSDWindowY + 10, 0, width, height);
  rect(PSDWindowY-1, 30, PSDWindowWidth+1, PSDWindowHeight+1, 5); //  PSD  window

  if (beatCount > rrData.length/2) // wait before displaying graph in order to gather some valid IBI data 
  {

    for (int i=0; i < spectrumArr.length/2; i++)
    {
      float raw = spectrumArr[i];
      // raw = 3500; // sets the value for testing the scale accuracy
      if (raw>4000) // keep from going into label
        raw = 4000;
      float fl = map(raw, 0, 4000, 0, 200);
      int barSpacing = 26;
      stroke(0, 255, 255);
      strokeWeight(7.0);
      line(PSDxPos+10+ (barSpacing*i), 230, PSDxPos+ 10+(barSpacing*i), 230-fl );

      fill(200, 255, 0);
      textSize(8.5);
      String rawStr = nf(raw, 1, 1);
      rawStr = rawStr.substring(0, rawStr.lastIndexOf("."));
      if (raw < 3900) {  // keep from printing over top label
        text(rawStr, PSDxPos + 0 + (barSpacing*i), 221-fl);
      }

      // print labels
      if (firstTime)
      {
        fill(0);
        textSize(11);
        text(PSDlabels[i], PSDxPos + 5 + (barSpacing*i), WaveWindowX-15);
      }
    }
    firstTime = false;
  } else
  {
    fill(255, 0, 0);
    textSize(14);
    text("Gathering Data", PSDxPos+40, 60);
    text(10-beatCount, PSDxPos+82, 80);
  }


  stroke(0);
  // at the edge of the screen, go back to the beginning:
  if (xPos*magnify >= width) { // uses magnify
    xPos = 1;
    fill(255, 255, 255);

    // re-draw main lower waveform window
    strokeWeight(2.8);
    rect(1, WaveWindowX, width-3, height-WaveWindowX-2, 5);
  }
}
////////////////////////////////////// END DRAW /////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     Serial Event ()                                                      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');  


  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);

    if (debug)
    {
      println(inString);
    }
    if (inString.contains("S") )
    {
      pulseData = false;
      if (debug)
      {
        println("S2: " + inString.replace("S", ""));
      }
      inString = inString.replace("S", "");

      inByte = float(inString);

      xPos++;

      inByte = map(inByte, 300, 600, 100, height-230) - yMod; //
    }
    // happens every time there is a beat
    if (inString.contains("B") )
    {
      

      pulseData = true;
      if (debug)
      {
        println("BPM: " + inString.replace("B", ""));
      }

      if (!flatLine)
      {
        BPM = int(inString.replace("B", ""));

        BPMxPos = BPMxPos + 1;
      }
    }

    // happens every time there is a beat
    if (inString.contains("Q") )
    {

      if (debug)
      {
        println("IBI: " + inString.replace("Q", ""));
      }
      if (!flatLine)
      {
        IBI = int(inString.replace("Q", ""));

        IBIxPos = IBIxPos+1; // + 1;

        beatCount++;

        if (beatCount > 10 && pulseData)
        {
          HFold = HF;
          LFold = LF;
          HLxPos = HLxPos+LFHFmagnify+1 ; // 2 just to stretch it out a bit
        }


        freq = (runningTotal/1000) * 2;   // scale milliseconds to seconds account for 1/2 wave data
        freq = 1/freq;                   // convert time IBI trending up to Hz 
        runningTotal = 0;                // reset this for next time
        amp = P-T;                       // measure the size of the IBI 1/2 wave that just happend 
        mean = P-amp/2;

        freqMappedVal = map(freq, 0, 2, FreqWindowY, FreqWindowWidth+FreqWindowY);
        freqMappedVal =  constrain(freqMappedVal, FreqWindowY, FreqWindowWidth+FreqWindowY); 

        powerPointX[pointCount] = freqMappedVal;  // plot the frequency
        powerPointY[pointCount] = map(amp, 0, FreqMaxVal, 200, 0);  // amp determines 'power' of signal
        pointCount++;                    // build the powerPoint array
        if (pointCount == maxDots) {
          pointCount = 0;
        }      // overflow the powerPoint array
        /////
        if (IBI < lastIBI && goingUp == true) {  
          goingUp = false;
          T = lastIBI;
        }

        if (IBI > lastIBI && goingUp == false) {  // check IBI wave trend
          goingUp = true;
          P = lastIBI;
        }

        if (IBI < T) {                        // T is the trough
          T = IBI;                         // keep track of lowest point in pulse wave
        }
        if (IBI > P) {                        // P is the trough
          P = IBI;                         // keep track of highest point in pulse wave
        }
        runningTotal += IBI;
        lastIBI = IBI;   

        int tempIBI = constrain(IBI, 0, 2000); // keeps values from going below zero which will cause and exception in the FFT calcs.
         
        if (beatCount < rrData.length) 
          rrDataStr += tempIBI + ",";
        else
          rrDataStr = rrDataStr.substring(rrDataStr.indexOf(",")+1 )  + tempIBI + ",";

        
        FFTprocess(); // process PSD Spectrum Data now that the IBI has been updated.
      }
    }
  }
}  //////////////////////////////////// end serial event



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                 PSD Spectrum : Fast Fourier Transform (FFT) calculations                        //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void FFTprocess()
{

  String newStr = "";
  newStr =  rrDataStr.substring(0, rrDataStr.lastIndexOf(",")) ;
  String[] rrDataArrStr;

  if (newStr.split(",").length > rrData.length/2) // make sure there are enough data elements to perform FFT calculation

  {
    rrDataArrStr = newStr.split(",");

    for (int i = 0; i< rrDataArrStr.length; i++)
    {
      rrData[i] = Float.parseFloat(rrDataArrStr[i]) ;
    }

    /// if there are default zero values in the data lets replace them with real values
    // the number of data elements available is less then the total number we want to evaluate 
    // rrData length is initialzied to the max size of the desired data elements to evaluate 
    // until max size is reached, there will be zeros in the evaluted data (throwing off the PSD calc)
    // so unti max size is reached will fill remaining rrData with values starting at the beginning of the string
    // which means the remaining rrData values are duplicates of the first values in the string unitl max size is reached 
    // and then the data starts shifting normally with all real valuess (no dupes)
    // This at least gives a more accurate graph until all values are filled.
    // if the values are left zeros, the chart will be way off.

    if (rrData.length > rrDataArrStr.length)
    {

      for (int i = 0; i< rrData.length - rrDataArrStr.length; i++)
      {
        rrData[i+rrDataArrStr.length] = Float.parseFloat(rrDataArrStr[i]) ;
      }
    }


    ///// serial debug printing
    if (debug)
    {
      println ( newStr );

      for (int i = 0; i< rrData.length; i++)
      {
        print ( rrData[i] + "," );
        //    rrData[i] = Float.parseFloat(rrDataArrStr[i]) ;
      }
      println(" ");
    }
  }

  FloatFFT_1D fftDo = new FloatFFT_1D(rrData.length);
  float[] fft = new float[rrData.length * 2];
  System.arraycopy(rrData, 0, fft, 0, rrData.length);
  fftDo.realForwardFull(fft);

  int cnt = 0;
  for (float d : fft) {
    cnt++;

    // print serial
    if (debug)
    {
      print(cnt);
      print(" fft: ");
      println(d);
    }
  }


  String ReStr = "";
  String ImStr = "0,"; // filler for Im[0] which doesn't exist and shouldn't be used in spectrum calculations

  
  for (int k=0; k < fft.length/2; k++)
  {
    ReStr += fft[k*2] + ",";
  }
  for (int k=1; k < fft.length/2; k++)
  {
    ImStr += fft[2*k+1] + ",";
  } 

  

  ReStr += fft[1]; // the last element in the vector Re[length/2] 
  ImStr = ImStr.substring(0, ImStr.lastIndexOf(","));

  
  if (debug)
  {
    print("ReStr ");
    println(ReStr);
    print("ImStr ");
    println(ImStr);
  }
  ///////////////////////////////////////


  String[] Re = ReStr.split(",");
  String[] Im = ImStr.split(",");


  String SpectrumStr = "";
  String UnitsStr = "";

  // calculate the spectrum data and setup the Hz scale labels
  for (int k=1; k<Im.length; k++)
  {
    double spectrum = Math.sqrt( Math.pow(Double.parseDouble(Re[k]), 2) + Math.pow(Double.parseDouble(Im[k]), 2) );

    SpectrumStr += spectrum + ",";
    double unit = ((double)k*(1.0/rrData.length)); // where 1.0 is 1 Hz sample rate

    String tmpStr = Math.round(unit*100)/100.0d + "";
    UnitsStr += tmpStr.substring(tmpStr.lastIndexOf(".")) + ",";
  }            

  SpectrumStr = SpectrumStr.substring(0, SpectrumStr.lastIndexOf(","));
  UnitsStr = UnitsStr.substring(0, UnitsStr.lastIndexOf(","));

  String[] spectrumStrArr = SpectrumStr.split(",");
  spectrumArr = new float[spectrumStrArr.length];

  PSDlabels = UnitsStr.split(",");


  if (debug)
    println("--------------------- spectrum data" );

  LF = 0;
  HF = 0;
  // fill the spectrum array with data
  for (int i=0; i<spectrumStrArr.length/2; i++)
  {
    spectrumArr[i] = Float.parseFloat(spectrumStrArr[i]);

    if (i <= 2) 
    {
      LF += spectrumArr[i];
    } else
    {
      HF += spectrumArr[i];
    }
    if (debug)
    {
      print("spectrum " ); 
      println(spectrumArr[i]);
    }
  }//  end for loop

  LF = LF/3;  // .05 .1 .15 (3 LF rows averaged)
  HF = HF/6;  // .2 .25 .3 .35 .4 .45 (6 HF rows averaged)

  if (debug)
  {
    print("UnitStr "); 
    println(UnitsStr);
  }
}

