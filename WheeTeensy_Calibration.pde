/*****************************************
  *  WheeTeensy_Calibration
  *   built from WheeTeensy_GUI_Core
  *   mouse tab
  *   find cursor method in setup
******************************************/

import grafica.*;                    // For chart classes.
import grafica.GPlot;
import controlP5.*;                  // for buttons and txt boxes
import processing.serial.*;          // for serial

////// calibration parameters
int bckgnd = #408644;  //#3C88A5;  color changed
ControlP5 cp5Cal;
Textfield Low_Ref, High_Ref, serial;
String serialNo;
boolean gotABC = false;          // parameters for calculated wavelengths

float[] deltaABC = new float[3];
int lamps = 0;
String[] source = new String[5];
float[][] xLambda = new float[5][5];  // five wavelengths, five sources
String sHigh_Ref, sLow_Ref;
int[][] xPixels = new int[5][5];


// variables for peak picking
 int xPick, yPick;  // pixel positions for cursor
 float lineWav;     // wavelength of cursor
 int xMinPix, xMaxPix;
 boolean[] selWav = {false,false,false,false,false};  // selected wavelength
 boolean[] setPix = {false,false,false,false,false}; // have pixels been set? 
 //boolean[] showPix
 int[] pixCal = {0,0,0,0,0};
 int specPixel = 0;  // pixel number in spectrum, not display pixel
 int peakNo;
 float specY;
 float specX;

 ///////// calculate least squares fit
   int nPeaks = 0;   // number of peaks in refinement
 boolean[] refined = {false,false,false,false}; // 0-2 are for ABC params, 3 is overall
 float[] peakObs = new float[5];  // wavelengths where peaks expected
 int[] peakPix = new int[5];      // pixels where peaks observed
 float[] peakCalc = new float[5];   // peak positions from calculation
 float[] storedDeltas = new float[3];
boolean gotData = false;
 
/// end of calibration parameters

//float[] ABC = {242, 0.146952, 0};  // used in conversion from pixels to wavelengths
float[] ABC = {0,0, 0};
String sIntTime = "2";  // input value for integration time
float intTime;          // value of integration time (needed?)

/////////// flags /////////////////
boolean reading = false;
boolean startRun = false;
boolean running = false;
boolean gotRef = false;          // reference spectrum retrieved from file
public GPlot plot, plot1, plot2, refPlot;

//float xMinRaw, xMaxRaw;
//float yMinRaw, yMaxRaw;
float yMin = 0;
float yMax = 40000;
int nPixels = 3648;
int readPixels;
GPointsArray data = new GPointsArray(nPixels);
GPointsArray refData = new GPointsArray(nPixels);   // reference data loaded from file
GPointsArray plotData = new GPointsArray(nPixels);
GPointsArray data1 = new GPointsArray(2);  // horizontal line
GPointsArray data2 = new GPointsArray(2);  // verticle line
int plotWidth, plotHeight;
int plotX;
int plotY;
String buffer;
String LampName = "Comp Fluor";

String[] strData = new String[4000]; // input saved here
float[] xData;
float[] wavelength = new float[nPixels];  // redundent? only need xData if pixels averaged
int counter;
int LINE_FEED = 10; 

String viewTxt = "Intensity";
float xMin = 400;  // are these used?
float xMax = 1000;
    float yMinRef = 0;
    float yMaxRef = 0;
    float xMinRef = 0;
    float xMaxRef = 0;

//////////// controllers /////////////////////
ControlP5 cp5, cp5Com;
Textfield integration_Time;

PFont font, font12;

  /////// serial communications /////////////
  Serial serialPort;
static String[] comList ;               //A string to hold the ports in.
String comStatTxt = "not connected";
boolean Comselected = false;     //A value to test if you have chosen a port in the list.

int comY = 25;
  
  
void setup() {
  size(800, 600); // (800, 700)
  
  plotWidth = width-150;    // position and dimensions of plot
  plotHeight = height-300; //240;
  plotX = 20;
  plotY = 60;
  
  ///////// cursor stuff ///////////////
   xMinPix = plotX +70;
   xMaxPix = plotWidth+plotX+70;

  xPick = plotWidth/2 + xMinPix;    // start with cursor in center
  yPick = plotHeight/2+ plotY+45;
  
//  xPick = xCenter;
//  yPick = yCenter;
  
  font = createFont("Arial", 14);
  font12 = createFont("Arial", 12);
  
  String[] headerInfo = loadStrings("calSetup.txt");
//println("cal setup data file read");
int size = headerInfo.length;
for (int g = 0; g<size; g++){
  readParLine(headerInfo[g]);  // in calibration tab
}

  setupComPort();  
  connect();

  cp5CalSetup();
  setupCharts();            // wavelengths calculated here?
  cp5_controllers_setup();


  findCursor();  // find position of cursor line in spectrum
  data1.add(0,0);
  data1.add(nPixels,0);
  data2.add(500,0);
  data2.add(500,60000);
}

void draw(){
  background(bckgnd); 
  textFont(font,14);
  fill(#080606);
 
   text(comStatTxt, 80, comY);  // displays com port state
   text("Serial: "+ serialNo,80,comY+16);
   text("SmokyMtSci.com",width-130,height-30);
if(reading == false){
  setAxes();
  try{
    plotCharts();
    } catch(Exception e){
      println("problem in plotCharts");
    }

int plotLo = plotY+40;
    ////////////// display wavelengths
    for(int h = 0;h<5;h++){
     if(selWav[h]){ fill(255);}
     else {fill(0);}
     text(nf(xLambda[0][h],0,1),400,height-110+h*20);
      if(setPix[h] == true){
        text(pixCal[h],450,height-110+h*20);
      }
      //// display lines highlighter for selected wavelengths ///////////
 if(gotRef){
   int a = findPosition(xLambda[0][h]);
      strokeWeight(20);
 //     stroke(yellow,40);
      stroke(250,250,0,60);
      line(a,plotLo+10,a,plotLo+plotHeight-10);
 }
    }
    strokeWeight(1);
    
    /////////// cursor stuff ////////
 stroke(0);
//int plotLo = plotY+40;
//line(xPick,plotLo,xPick, plotLo+plotHeight);
rectMode(CENTER);
noFill();
rect(xPick,yPick,15,15);
//rect(xPick,yPick,80, 240); //2*pickDelta,6*pickDelta);
fill(0);
text(nf(lineWav,0,1)+" nm", xPick,plotY+30);
//text(nf(specX,0,1)+" nm", xPick,plotY+30);
stroke(255);
  }
}
