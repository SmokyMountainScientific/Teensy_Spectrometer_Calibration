/**********************************
 * controllers tab, WheeTeensy_GUI_Core
 *   sets up buttons, textbox
 *   below setup are methods:
 *       startRun - initiates run
 *             - clears old data
 *             - get integration time from textbox
               - send integration time and start signal to instrument
 *       save  - saves data to user selected file
**********************************/

  void cp5_controllers_setup(){
    cp5 = new ControlP5(this);
      int lowY = height -60;
    
     integration_Time = cp5.addTextfield("Integration_Time")
            .setPosition(40, lowY-60)               // new
              .setSize(50, 25)
                .setFont(font12)
                    .setText(sIntTime);   
                  
  cp5.addButton("Start_Run")
            .setPosition(40, lowY)
              .setSize(80, 40)
                      ;
                                                      
  cp5.addButton("Save")
            .setPosition(450, 20)
              .setSize(50, 25) ; 
              
  cp5.addButton("Load")
            .setPosition(570, 20)
              .setSize(50, 25) ; 
              
 serial = cp5.addTextfield("serial")
            .setPosition(275, 20)               // new
              .setSize(40, 25)
                .setFont(font12)
                    .setText("XXXX");
                    
 cp5.addButton("Set_Serial")
            .setPosition(325, 20)
              .setSize(50, 25) ; 
}

/*********************************************
 *  methods associated with buttons
 *****************************************/
 
public void Start_Run() {  // start run
 // remove existing data from array ///
 println("starting run");
 int a = data.getNPoints(); //1000;
 println("data in array: "+a);
 if(a > 1000){
  data.removeRange(0,a);
  println("data removed");
 }  
  counter = 0;
  String stTime, IntTime, commands;
  stTime = cp5.get(Textfield.class, "Integration_Time").getText();
  int iIntTime = round(float(stTime)*1000);
  IntTime = nf(iIntTime, 6);   // make ScanR have 3 digits. pad with zero if no digits
  commands = "I"+IntTime+"&";
  running = true;
  
   serialPort.write(commands);
   println("running flag set");
   println("commands: "+commands);
}

public void Save(){
    selectOutput("File to save:", "fileSelected");
}

void fileSelected(File selection) {
  println("in fileSelected");
  String fileName = selection.getAbsolutePath();
  println("File name: "+fileName);
  String xPoint, yPoint;
  int strings = data.getNPoints();  
  String[] files = new String[strings+1];  
  files[0] = "wavelength,intensity";
  for(int i = 0; i<strings; i++){
    xPoint = str(data.getX(i));
    yPoint = str(data.getY(i));
    files[i+1] = xPoint+","+yPoint;
  }
  saveStrings(fileName, files);
}

public void Load(){
   println("load file button pressed");
   selectInput("Select a data file:", "fileToLoad");

}

void fileToLoad(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } 
  else {
  println("in fileToLoad loop, line 102, controllers tab");
    String[] file2str = loadStrings(selection.getAbsolutePath());    // load file
    String[] headers = split(file2str[0],',');  // split the first line
    println("first line: "+ file2str[0]);
  //  println("first header: "+ headers[0]);
    String[] sText = split(file2str[1],','); 
    int nSpectra = sText.length-1;
     nPixels = file2str.length;
    println("data size: "+nPixels);  //1400
    yMinRef = 0;
    yMaxRef = 0;
    xMinRef = 1000;
    xMaxRef = 0;
    
    String RefFileName = sText[1];
    if(gotRef){
      println("removing older data from reference file");
      refData.removeRange(0,nPixels-1);    // erase data from refData
    }
    gotRef = true;
    reading = false;
    gotData = true;
    
    println("gotRef set true, reading false");
    for(int p = 1;p<nPixels-1; p++){
      try{
      String[] tokens = split(file2str[p],',');
      float xVal = float(tokens[0]);
      float yVal = float(tokens[1]);
      refData.add(xVal,yVal);
      if(yMinRef > yVal){
        yMinRef = yVal;
      }
      if(yMaxRef < yVal){
        yMaxRef = yVal;
      }
      if(xMinRef > xVal){
        xMinRef = xVal;
      }
      if(xMaxRef < xVal){
       xMaxRef = xVal;
      }
      } catch(Exception e){
       println("problem with pixel "+p); 
      }
    }
    refData.removeInvalidPoints();
    
    // stuff below copied from Wheetrometer_Teensy1 //
    /*
    for(int h = 0; h<nSpectra; h++){
       RawSpecList.add(new GPointsArray()); 
    }
    if(nSpectra+spectra >20){
    iError = 2;  // error message
    errorFlag = true;
    } else {
          print("display spectra: ");
for (int i=spectra; i<nSpectra+spectra; i++){  // set all new spectra visible
  selectBox[i] = true;
  print(i+", ");
}
println("");
    println("number of spectra to add: "+nSpectra);
    
    */

    
         ///  for each spectrum ///
/*         println("initial spectra: "+spectra+", adding "+nSpectra);
    for (int p = spectra; p< spectra+nSpectra; p++){
     sFileName[p] = headers[p+1];
     println("File name "+p+": "+sFileName[p]);
     cHeader[p] = sFileName[p];  // file name for processed data, change later
  //   println("line 137");
     GPointsArray array = RawSpecList.get(p+spectra);  // spectra the old number?

     yMinRaw[p+spectra] = 0;
     yMaxRaw[p+spectra] = 0;
  //        println("line 142");
          
          /// for each wavelength  ///
         for (int j = 0; j<nPixels-2; j++){

       String[] tokens = split(file2str[j+1],',');
           if(tokens[p] == null){
             println("empty thing");
           }
           else{
             
  float xValue = float(tokens[0]);
  float yValue = float(tokens[p+1]);
  // set limits
  if(spectra+p == 1){
    if(j==0){
  xMin[0] = xValue;
  xMin[1] = xValue;
 println("got min x");
}
else if (j==nPixels-3){
  xMax[0] = xValue;
  xMax[1] = xValue;
   println("x min[0] = "+xMin[0]+", x max[0] = "+xMax[0]);
} else {}
  }
  try{
      if(yValue < yMinRaw[p+spectra]){
      yMinRaw[p+spectra] = yValue;
      }
      if(yValue > yMaxRaw[p+spectra]){
     yMaxRaw[p+spectra] = yValue;
      }
  } catch(Exception e){
    println("fucked up setting limits, line 172, spectrum "+p+", pixel "+j);
  }
      try{
  array.add(xValue,yValue);
      }
      catch(Exception e){
        println("fucked up line 172");
      }
           }
    }  // end of pixels loop
    println("size of data set "+p+": "+ array.getNPoints());    
    }

//spectra += nSpectra;                // add new spectra to list 
//println("spectra: "+spectra);
//  }
     getYLims();  */
  }
}


void Set_Serial(){
  println("serial button pressed");
  String Serial = "N";
  Serial = Serial+cp5.get(Textfield.class, "serial").getText();
  println("serial: "+Serial); 
 try{ serialPort.write(Serial);}
 catch(Exception e){
   println("problem in serialPort.write");
 }
}
  
