/****************************
 *  Mouse tab in WheeTeensy calibration 
 *     mousePressed pick wavelength
 *     mouse dragged  move cursor
 *     findCursor method
 ********************************/
 void mousePressed(){
   int xWvMin = 400;
   int xWvMax = 460;
   int yWvMin = height-130;
   if(mouseX > xWvMin && mouseX <xWvMax){
     for (int r = 0; r<5; r++){
     if(mouseY> yWvMin+20*r && mouseY < yWvMin+20*r+20){
       selWav[r] =! selWav[r];
     }
     }
   }
 }
 
 void mouseDragged(){
  int delta = 40;
  //////////// keep cursor on plot /////////
  if(mouseX < xMinPix){
    xPick = xMinPix;
  } else if (mouseX > xMaxPix){
    xPick = xMaxPix;
  }
  if(mouseX > xPick-delta && mouseX < xPick+delta && mouseY >yPick-delta && mouseY < yPick+delta){
   xPick = mouseX;
   yPick = mouseY;
 }
 findCursor();
 }

void findCursor(){  // find wavelength of cursor
   int pixWidth = plotWidth; //3646;  // width  of display in pixels
//   linePix = int((xPick-90)*plotWidth/660);
 //  yCenter = 495-yPick;
 int y = xPick-xMinPix;
 int z = xMaxPix - xMinPix;
 
 float fraction = float(y)/z;
  // float fraction = float((xPick-xMinPix)/(xMaxPix-xMinPix));
//   println("xPick: "+xPick+", xMinPix: "+xMinPix+",X max Pix: "+xMaxPix+", fraction: "+fraction);
   lineWav = (xMax-xMin)*fraction+xMin;
   // here is the problem, spectra pixels are not linear with wavelength
   //   need to map the wavelength to the pixel
   float delta = sin(PI*fraction);
   delta *= ABC[2];
   float estPix = lineWav - ABC[0] - delta; 
   estPix /= ABC[1];   // should be on low side of pixel number
  // specPixel = int(fraction * nPixels);
   specPixel = int(estPix);
   try{
   specY = data.getY(specPixel);
/*   float intX = data.getX(specPixel);
   specX = sin(PI*intX/nPixels);
   specX *= ABC[2];
   specX += intX*ABC[1];
   specX += ABC[0]; */
   specX = data.getX(specPixel);
   data1.set(0,xMin,specY,"start");
   data1.set(1,xMax,specY,"finish");
   data2.set(0,specX,yMin,"start");
   data2.set(1,specX,yMax,"finish");
//   println("data point: "+specX+", "+specY);
//   println("spec Y: "+specY);
   } catch(Exception e){}
 //  println("xPick: "+xPick+", cursor at "+lineWav);
}

int findPosition(float wav){   // return postion of wavelength
  float delta = xMaxRef-xMinRef;
  float fraction = (wav-xMinRef);
  fraction /= delta;
  int value = xMinPix+int(fraction*(xMaxPix - xMinPix)) ;
 return value; 
}
