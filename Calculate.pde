/*************************
* Calculate tab
*  calculate()  
*  wavelengthCalc  - determine wavelength
*  calculateResid  - calculates residuals
*  refine() - refines one parameter
*************************/

void calculate(){     // use peak positions to calculate wavelengths
for(int r = 0; r<3; r++){
 deltaABC[r] = storedDeltas[r]; 
}
 refined[3] = false;
 
 /*int size = data.getNPoints();     // get number of data points in array
 float[] xVals = new float[size];    // set up array of x values
          */         // number of peaks to use
  nPeaks = 0;
  for (int y = 0; y<5; y++){
   if(selWav[y] == true){
     peakObs[nPeaks] = xLambda[0][y];
     peakPix[nPeaks] = pixCal[y];
   nPeaks++;        // number of peaks to use in refinement
     }
  }
  println("in calculate method, number of peaks used: "+nPeaks);
  if(nPeaks == 0){
    println("error: no peaks selected");
 //   errorFlag = true;
  //  iError = 5;
  }
  else if(nPeaks == 1){  // shift using existing slope
  float minX = data.getX(0);
  float maxX = data.getX(nPixels-1);

  ABC[1] = (maxX - minX)/nPixels;              //  current slope
  }else if(nPeaks == 2){
   ABC[1] = (peakObs[1] - peakObs[0])/(peakPix[1] - peakPix[0]);   // estimate slope
  
  ABC[0] = - ABC[1]*peakPix[0]+peakObs[0];  // estimate intercept
  } 
  
  else{

  /*********************************
  *  begin least squares refinement
  ***********************************/ 
  
//  float R = calculateResid(nPeaks);
  float resid0 = calculateResid();   //initial residual value
  float resid1 = 0;
  
  println("initial constant values:");
  println("zero order: "+ABC[0]+", 1st order: "+ABC[1]+", sin correction: "+ABC[2]); 
  println("initial R^2: "+resid0);
    
  
  for(int p = 0; p<4; p++){  // go through four itterations
    refined[3] = false;
  while(refined[3] == false){

  refine(0);
  refine(1);
  refine(0);
  refine(2);
  refine(0);
  refine(1);
  refine(0);
  resid1 = calculateResid();
  println("Residual cycle "+p+": "+resid1);
  if(resid1>=resid0){
    refined[3] = true;
  }else{
  resid0 = resid1;

   }
  }
        for (int w = 0; w<3; w++){   // moved from above
      deltaABC[w] = deltaABC[w]/2;   // change size of iteration for finer refinement
      refined[w] = false;
    }
    
      println("zero order: "+ABC[0]+", 1st order: "+ABC[1]+", sin correction final: "+ABC[2]); 
  println("initial R^2: "+resid0);
  }  // end of p loop

 }
/* float f;
 for(int t = 0; t<size; t++){
   f = sin(PI*t/size);
  xVals[t] = (ABC[1]*t)+ABC[0] + ABC[2]*f;     //  calculate wavelengths
//  for(int w = 0; w<spectra; w++){     // set wavelengths in each array
 //   GPointsArray array2 = RawSpecList.get(w);
    data.setX(t,xVals[t]);
//  }
 }
 for(int i = 0; i<3; i++){  // dont reset zoom
 xMin = xVals[0];    // reset x axes
 xMax = xVals[size-1];
  }
  */
 // println("storedDeltas[0]: "+storedDeltas[0]);
//  deltaABC = storedDeltas;   // restore deltas to original values
  println("deltaABC[0]: "+deltaABC[0]);
//  params();  // gets parameters from text boxes?
//  wavelengthCalc();  // these two methods are in Charts tab
//  setAxes();
//  newXVals();        // this one either
print("Observed:   ");
  for(int h = 0; h<nPeaks; h++){
   print(peakObs[h]+", ");
  }
  println("");
  print("Calculated: ");
  for(int h = 0; h<nPeaks; h++){
   print(nf(peakCalc[h],0,4)+", ");  // print 4 digits
  }
  /**************************
  *  update baseline in data array
  ***************************/
  wavelengthCalc();
    for(int t = 0; t< readPixels-1; t++){
   data.setX(t,wavelength[t]); 
  }
  xMin = wavelength[0];
  xMax = wavelength[readPixels-1];
  plot1.setXLim(xMin, xMax);
  }


float calculateResid(){
  float residSq = 0;
  float sQ = 0;
  float f = 0;
  float d;
  for(int a = 0; a <nPeaks; a++){
    f = sin(PI*peakPix[a]/3647);
  peakCalc[a] = (peakPix[a]*ABC[1])+(f*ABC[2])+ABC[0];
  d = peakCalc[a] -  peakObs[a]; 
  sQ = sq(d);
  residSq = residSq + sQ; 
  }
//  println ("R squared: "+residSq);
  return residSq;
 }
 
   
 float refine(int a){
   float oldResid = calculateResid();
   float newResid = 0;
   float oldConst = ABC[a];
   refined[a] = false;
       boolean increment = true;
     while(refined[a] == false){
     if(increment == true){
       ABC[a] += deltaABC[a];    // increment constant
     } else {
       ABC[a] -= deltaABC[a];    // decrement constant
     }
     newResid = calculateResid();
     if(newResid < oldResid){
     oldResid = newResid;
     oldConst = ABC[a];   // ... and we go round again...
     } else {
      ABC[a] = oldConst;
      increment =! increment;
      if(increment == true){
        refined[a] = true;
     }
     }  //  end of else
     }  // end of refined is false loop
 //    println("new R squared: "+oldResid+", new parameter "+a+" params: "+ABC[0]+", "+ABC[1]+", "+ ABC[2]);
        return oldResid; 
 }  // end of refine method
 
