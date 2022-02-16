/*************************************
 *  readSerial tab, WheeTeensy_GUI_Core sketch
 *    serialEvent method
 *    convert Data method
 **********************************/
 
 void serialEvent(Serial p){

  if(Comselected == false){
  } else {  // if comSelected is true

 buffer = null;
  buffer = p.readStringUntil(LINE_FEED);
  if(buffer != null){
    ///////// look for special characters ////////
 //   int j = buffer.indexOf("$");      // parameters recieved by ucontroller
    int k = buffer.indexOf("!!!");      // end signal  was !
    int m = buffer.indexOf("00,");        // zero is first index
 //   int w = buffer.indexOf("DatEr");  // data recording error
    int x = buffer.indexOf('/');      // comment from firmware
    int y = buffer.indexOf('B');
/*    if(m == 2){
      print("data point received: ");
      println(buffer);
    }*/
    if(k!=-1){    // end of data signal from microcontroller recieved
      running = false;
      reading = false;
      println("! signal received");
      strData[counter] = buffer;
      println("end string "+counter+": "+buffer);
      convertData();
      
    } else if (x!=-1){  }     // ignore comments from microcontroller
    else if (y !=-1 && gotABC == false){         // get baseline data
    println("getting baseline values");
    try{
    String[] tokenABC = split(buffer,",");
    ABC[0] = float(tokenABC[0].substring(1,7));
    ABC[1] = float(tokenABC[1]);
    ABC[2] = float(tokenABC[2]);
    gotABC = true;
    println(" got baseline values");
    }
    catch(Exception e){
    println("  problem reading ABC values");
    gotABC = false;
    }
    }
    
    /*********************************************
    *  Collect spectral data
    ***************************************/
  else if(running == true) {
    //    put data in strData array
  strData[counter] = buffer;
  counter++;
  /*****************
  *  the following println statement was for diagnosing issues
  *    where data was lost, it looks like data after about 2915 pixels 
  *    did not get into the buffer.  It looks like adding a 200 us delay 
  *    in the firmware between serial prints fixed it
  *    If this problem arises again, try sending data in packets of 1200 points or so
  *
  *******************/
  /*
  if(counter>2910){
    println("buffer: "+buffer);
  }  */
  }
  else{ }       // if running is false
  /*   // below for recieving parameters from microcontroller
    strParams[pCount] = buffer;
      println("collecting parameter "+pCount+", line 48");
    pCount++;

  println(buffer);
  }      */
   }  // end of if buffer not null loop
   else{ } // if buffer is null dont do anything
  } // end of com selected is true loop
} // end of serial event


/***********************************************
*  Convert data from strings
*   and put data into GPoints array
*********************************************/

void  convertData() {
//  boolean test = true;     // generate test file

  yMin = 0;
  yMax = 0;
 int pixelNo = 0;
  println("in convertData loop");
println("data strings: "+counter);
for(int h = 1; h<=counter-5; h++){  // changed from counter to counter - 5

  char check;
  int value0 = 0;

   check = strData[h].charAt(0);
   if(check== '!'){       // ! indicates end of data
        println("end signal recieved, line 86");
          data.removeInvalidPoints();
        }else{
          try{
      // split into strings at ','
      String[] tokenDat = split(strData[h],",");
      value0 = Integer.parseInt(trim(tokenDat[1]));
  if(h%1000 == 0){
  println("counter: "+h+", "+strData[h]);
//  println("value: "+value0);
  }
 }
 catch(Exception e){
  println("problem parsing data at line "+h);
}
      if(value0<yMin){
        yMin = float(value0);
      }
      if(value0>yMax){
        yMax = float(value0);
      }
   pixelNo++;
//array2.add(xData[pixelNo],value0);
  data.add(wavelength[pixelNo],value0);
        }
 }
 // end of h loop
 data.removeInvalidPoints();  // copied from above
 readPixels = data.getNPoints();
 println("number of CCD pixels read: "+readPixels);
 println("xMin: "+xMin+", xMax: "+xMax+", yMin: "+ yMin+", yMax: "+yMax);
// getYLims();
//yMin = yMin;
//yMax = yMax;
 println("end of convert data method");  //not getting here
 gotData = true;
}
