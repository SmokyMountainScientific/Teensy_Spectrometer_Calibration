/********************************************
 *   chartsSetup tab, Wheetrometer_Teensy_GUI_Core
 *     methods: setupCharts
 *       wavelengthCalc
 *     setAxes
 *     plotCharts
 ******************************************/

void setupCharts(){

 ////////////////////////////////grafica uses GPlots
  plot = new GPlot(this);

  plot.setPos(plotX, plotY);
  plot.setDim(plotWidth, plotHeight);
  plot.setXLim(xMin, xMax);
  plot.setYLim(0, 800);

    plot1 = new GPlot(this);
    refPlot = new GPlot(this);

  plot1.setPos(plotX, plotY);
  plot1.setDim(plotWidth, plotHeight);
  plot1.setXLim(xMin, xMax);
  plot1.setYLim(0, 800);
  
  plot2 = new GPlot(this);

  plot2.setPos(plotX, plotY);
  plot2.setDim(plotWidth, plotHeight);
  plot2.setXLim(xMin, xMax);
  plot2.setYLim(0, 800);

  // need to add fake data?
  wavelengthCalc();  // method below
//  newXVals();  // method below
}

void wavelengthCalc(){
      print("wavelengths ");

if(gotABC == false){
ABC[0] = 200;
ABC[1] = 0.12;
ABC[2] = 35;

}
 try{
        // data size should be 3648
 float f =0;
 float a = PI/nPixels;
  for (int h = 0; h < nPixels; h++){
  //f = sin(PI*h/nPixels);
   f = sin(h*a);
  float g = ABC[2]*f;
//  float g = 0*f;
  // wavelength[h] = ABC[0] + (ABC[1]*h) +(ABC[2]*f);
    wavelength[h] = ABC[0] + (ABC[1]*h);
    wavelength[h] += g;
//   xData[h] = wavelength[h];
 //   data.setX(h,wavelength[h]);  // why does this not work?
    }
    xMin = wavelength[0];
    xMax = wavelength[nPixels-1];
    println("calculated xMin: "+xMin+", xMax: "+xMax);
}
catch(Exception e){
  println("baseline calc fuddkup, charts tab, wavelengths method");
  }
}



void setAxes(){
  plot.getXAxis().getAxisLabel().setText("Wavelength (nm)");
  plot.getYAxis().getAxisLabel().setText("Intensity");
  plot.getTitle().setText("Spectral data");

  plot.setXLim(xMin,xMax);
  plot.setYLim(yMin,yMax);
  }

void plotCharts(){
 // println("plotting");
  float[] yLims = {yMin,yMax};
  int h = plotHeight;
  if(gotRef){
    yLims[1] *=2;
  }

  plot.setPoints(data);
  plot.setPoints(data);
  plot.setYLim(yLims);
  plot.setXLim(xMin,xMax);
  plot.setPos(plotX,plotY);
  plot.setDim(plotWidth, plotHeight);
  plot.setLineColor(0);
try{
     plot.beginDraw();
  //   if(ref == false){
      plot.drawBackground();
 //    }
      plot.drawBox();
      plot.drawXAxis();
      plot.drawYAxis();
  //    plot.drawTitle();
      plot.drawLines();
      plot.endDraw();
} catch(Exception e){
 println(" problem in setup, line 104");
}
  if(gotData == true){ 
    try{
  plot1.setPoints(data1);
  plot1.setYLim(yLims);
  plot1.setXLim(xMin,xMax);
  plot1.setPos(plotX,plotY);
  plot1.setDim(plotWidth, plotHeight);
  plot1.setLineColor(0);
      
     plot1.beginDraw();
     plot1.drawLines();
     plot1.endDraw();
  } catch(Exception e){
    println("problem in plot1");
  }

try{
  plot2.setPoints(data2);
  plot2.setYLim(yLims);
  plot2.setXLim(xMin,xMax);
  plot2.setPos(plotX,plotY);
  plot2.setDim(plotWidth, plotHeight);
  plot2.setLineColor(0);
} catch(Exception e){
  println("problem setting data2");
  float a = data2.getX(0);
  float b = data2.getX(1);
  float c = data2.getY(0);
  float d = data2.getY(1);
  println("point 0: "+a+", "+c+ ", point 1: "+b+", "+d);
}
try{
  plot2.beginDraw();
     plot2.drawLines();
     plot2.endDraw();
} catch(Exception e){
  println("problem in plot2");
}

if(gotRef){
  
  int pts = refData.getNPoints();
//  println("Reference data points: "+pts); // gives 3644 points
//  println("in reference plot loop");
     yLims[0] = yMinRef;
    yLims[1] = yMaxRef;
//     yLims[0] = yMin;
  //  yLims[1] = yMax;
  try{
  refPlot.setPoints(refData);
   }catch(Exception e){
//    println("problem setting refPlot data");
  }
  refPlot.setYLim(yLims);
  refPlot.setXLim(xMinRef,xMaxRef);
  refPlot.setPos(plotX,plotY);
  refPlot.setDim(plotWidth, plotHeight/2);
  refPlot.setLineColor(#D66C6C);
try{
  refPlot.beginDraw();
     refPlot.drawLines();
     refPlot.endDraw();
} catch(Exception e){
  println("problem in refPlot");
}
}  // end of if got ref loop
  }
}
