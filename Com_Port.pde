/* Com_Port tab on WheeTeensy_GUI_Core
* code on this tab sets up communications with the microcontroller
* setupComPort
* connect() - method called in setup and whenever connect button pressed
*     - sets up to receive baseline calibration data from u-controller
*     -  sends '*' char to microcontroller, listens for response: '&' + serNo
*     -  once response recieved, sends '@' char which triggers u-controller
*        to send baseline paramaters, ABC
*/
void setupComPort() {
  /////////  connect button ////////////
  cp5Com = new ControlP5(this); 
  cp5Com.addButton("connect")
    .setPosition(20, 20)
      .setSize(50, 30)
        ;
}

/////////// connect button program //////////
public void connect() {
  Comselected = false;
  println("connect button pressed");
  try {
       serialPort.clear();
       serialPort.stop();
  }
    catch(Exception e) {}
    
    gotABC = false;
 // boolean[] gotABC = {false,false,false};   // do not have baseline parameters yet
   
  comList = null;
  comList = Serial.list(); // collect names of available ports  
  int n = comList.length;  // the number of available ports
  println("com list length = "+n);
  if (n == 0) { 
      comStatTxt = "No com ports detected";
  }
  else {
    int k = 9999;
    for (int m = 0; m <= n-1; m++) {
      try {
      serialPort = new Serial(this, comList[m], 115200);
      serialPort.write('*');   // initiate contact
      // listen for return character '&'
      delay(100);
      if (serialPort.available () <= 0) {
        println (comList[m]+" not responsive");
      }
      else {
        buffer = null;
        buffer = serialPort.readStringUntil(LINE_FEED);
        int y = buffer.indexOf("&");
        if(y!=-1){
          println (comList[m]+" responsive");
          k = m;
  /***********************************
   *  code for reading and displaying serial number
   *    must be available from microcontroller
  ************************************/
                    try{
            serialNo = buffer.substring(1,5);   // expects four char string
          println("Serial: "+serialNo);
          }
          catch(Exception e){
            println("no serial no avialable");
          } 
          
        }else {
          println("Com port says: "+buffer);
        }
        serialPort.clear();
        serialPort.stop();
      }
    }                       //  end of try loop
          catch(Exception e) {

      print(comList[m]);
      println(" not responsive");
    }    /// end of catch thing ///////////////

    }  // end of itterative look at ports
    if (k == 9999) {
      comStatTxt = "No response";
    } else {
      serialPort = new Serial(this, comList[k], 115200); 
      comStatTxt = "Connected on "+comList[k];
 //     serialNoTxt = "Spectrometer: "+serialNo;

      Comselected = true;
    }
    
  } // end of at least one port loop
  
  /*
  *
  * Get parameters (integration time, loops, averaging) 
  *   code below for parameter file stored on host computer
  *   values are separated by commas in text file "Setup.txt"
  */
  if(Comselected == true){  // get params from file
   serialPort.write('@');  // signal to send baseline parameters
   println("'@' char sent");
  }
/*   try{
    String[] paramFile = loadStrings("Setup.txt");
    
    int size = paramFile.length;
   // println("file length: "+size);
    int expNo = 0;    // experiment number
    for(int p = 0; p<size; p++){
      String[] tokens = paramFile[p].split(",");
      println(tokens[0]);
      if(tokens[0].indexOf(serialNo) != -1){
        expName[expNo] = tokens[1];
        sIntTime[expNo] = tokens[2];
        stLoops[expNo] = tokens[3];
        stAvg[expNo] = tokens[4];
        sMin[expNo] = tokens[5];
        sMax[expNo] = tokens[6];
        expNo++;
      }
    }
    if(expNo == 0){
      errorFlag = true;
      iError = 7;
    }
  } catch(Exception e){
    println("problem with paramFile");
  }  
  }else {  // use dummy values
  }
  int abc = (int('a')<<16);  //+(int('b')<<8) + (int('c'));
  println("Value of abc: "+abc);
  */

}
