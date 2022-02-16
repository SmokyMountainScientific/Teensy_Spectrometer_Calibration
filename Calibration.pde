/*******************************************
 *  Calibration tab, WheeTeensy_Calibration sketch
 *    cp5Cal setup
 *     buttons and textfields
 *    readParLine - gets parameters from txt file
 *    select_wav - gets wavelengths for least squares refinement 
 *          of baseline (refinement in calculation tab)
 ****************************************/
 
   void cp5CalSetup(){
    cp5Cal = new ControlP5(this);
      int lowY = height -60;
      int refX = 180;
    
     Low_Ref = cp5Cal.addTextfield("Low_Ref")
            .setPosition(refX, lowY-60)               // new
              .setSize(50, 25)
                .setFont(font12)
                    .setText(sLow_Ref); 
                    
     High_Ref = cp5Cal.addTextfield("High_Ref")
            .setPosition(refX, lowY)               // new
              .setSize(50, 25)
                .setFont(font12)
                    .setText(sHigh_Ref);
                    
                  
  cp5Cal.addButton("Set_Ref")
            .setPosition(refX+80, lowY)
              .setSize(60, 30)
                      ;
  int (refX = 540);
  
   cp5Cal.addButton("Lamp")
            .setPosition(refX, lowY - 60)
              .setSize(60, 20)
                      ; 
   
   cp5Cal.addButton("Select_Wav")
            .setPosition(refX, lowY)
              .setSize(60, 20)
                      ; 
   
   cp5Cal.addButton("Refine")
            .setPosition(refX, lowY-30)
              .setSize(60, 20)
                      ;
     cp5Cal.addButton("Write_Cal")
            .setPosition(refX+80, lowY-30)  // x was 580
              .setSize(60, 20)
                      ;  
   }
   
void Set_Ref() { 
    println("setting high and low references");
    //  get values //////
    String sLow, sHigh, commands;
  sLow = cp5Cal.get(Textfield.class, "Low_Ref").getText();
  sHigh = cp5Cal.get(Textfield.class, "High_Ref").getText();
  commands = "R"+sLow+","+sHigh;
     println("setting high and low references: "+commands);
     serialPort.write(commands);  
  }

void readParLine(String line){
  int xPix = 0;
    try{
      if(line.indexOf("//")==-1){  // if not a comment
      String[] tokens =line.split(",");
      if(tokens[0].indexOf("R")!=-1){  // refinement parameters
        println("R found");
        for(int y = 1; y<4; y++){
    //    deltaABC[y-1] = float(tokens[y]); // get refinement params
        storedDeltas[y-1] = float(tokens[y]);
     }
      println("refine parameter[0]: "+deltaABC[0]);
     }

/*     else if(tokens[0].indexOf("C")!=-1){  // baseline calibration parameters  
     ABC[0] = float(tokens[1]);
     ABC[1] = float(tokens[2]);
     ABC[2] = float(tokens[3]);
     }
     
     */

    else if(tokens[0].indexOf("W")!=-1){  // Wavelength parameters
     lamps++;
     println("reading info for lamp "+lamps);
     source[lamps-1] = tokens[1];
     int s = tokens.length;
     for(int u = 2; u<s; u++){
        xLambda[lamps-1][u-2] = float(tokens[u]);
     }
     }
     else if(tokens[0].indexOf("X")!=-1){  // refinement parameters
    xPix++;
    int s = tokens.length;
  for(int u = 1; u<s; u++){
    int v = u-1;
    xPixels[xPix-1][v] = int(tokens[u]);
   }
     } 
        else if(tokens[0].indexOf("F")!=-1){  // offset voltages
  sLow_Ref = tokens[1];
  sHigh_Ref = tokens[2];
     }
   else {}
      }
    }  // end of try
    catch(Exception e){
      println("problem in read parameters method");
    }
  }
  
  void Select_Wav(){
    float HiY = 0;
    int maxPix = 0;
    int p = 0;
    
    println("in Select_Wav function");
    for(int r = 0; r<5; r++){  // assumes five peaks
  if(selWav[r] == true){  // peak selected
   p++; 
   peakNo = r;
   println("finding peak "+r);
   selWav[r] = false;
  }
  if(p !=1){
   println("error: number of peaks picked is "+p); 
  } 
  else{
    setPix[peakNo] = true;
    println("picking high point within 50 pixels of pixel "+specPixel);
   // int min = xPick -100;

    HiY = 0;
   float compY;    // comparison value
    for(int j = specPixel-50; j<specPixel+50; j++){  // was -200 and +100
      compY = data.getY(j);
      if(compY > HiY){
        HiY = compY;
        maxPix = j;
      }
    }
      pixCal[peakNo] = maxPix;
     println("pixel number "+maxPix+", wavelength: "+ xLambda[0][peakNo]+", intensity: "+HiY);


    }
   
    
  }  // end of else
    
  }
  
  void Refine(){
    println("refine button pressed");
    gotABC = true;
    calculate();
  }
  
   void Write_Cal(){
        println("Write_Cal button pressed");
 // }
  
  ///// coppied from Calibtrometer sketch ///////
 //   void write_ABC(){
   String commands = "B";
   try{ // turn ABC values into six char strings
   println("ABC[0]: "+ABC[0]);

   for(int n = 0; n<3;n++){
   String aStr = str(ABC[n]);
   int r = aStr.indexOf("0");
   if(r == 0){
     aStr = aStr.substring(1,7);
   }else{
   aStr = aStr.substring(0,6);
   }
   println("ABC["+n+"]: "+aStr);
   commands = commands+aStr+",";
   }
   println("command string: "+commands);
   } catch(Exception e){
     println("Problem in writeABC method");
   }
   try{
     serialPort.write(commands);
   } catch(Exception e){
   println("error in writing baseline parameters");
 }
 }
 
 public void Lamp(){
  println("lamp button pressed");
  selectInput("Select a lamp file:", "LampFileToLoad");
 }
 
 void LampFileToLoad(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } 
  else {
  println("in LampFileToLoad loop, line 205, calibration tab");
    String[] file2str = loadStrings(selection.getAbsolutePath());    // load file
 //   String[] headers = split(file2str[0],',');  // split the first line
    //
int size = file2str.length;
for (int g = 0; g<size; g++){
  int r = file2str[g].indexOf("//");
  if(r == -1){
  String[] tokens = file2str[g].split(",");
  LampName = tokens[0];
  println("lamp: "+LampName);
  for(int u = 0; u<5; u++){
    
    print("wavelength "+u+ ": ");
 //   println(file2str[g]);
    println(tokens[u+2]);
    xLambda[0][u] = float(tokens[u+2]);
  }
  }
  
}
  } // end of else
 }
