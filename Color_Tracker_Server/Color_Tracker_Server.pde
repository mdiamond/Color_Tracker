/* 
 * Matthew Diamond 2014
 */

import processing.video.*;
import processing.net.*;

//Colors
color white;
color black;
color green;
//The color trackers
Tracker xy;
Tracker yz;
//Cameras for the trackers
Capture cam;
Capture cam1;
//A list of the cameras available for use
String[] cameras;
//The server
Server server;

/*******************/
/*     HELPERS     */
/*******************/

/* 
 * Initialize all major objects and variables
 */
void initialize(){
  //Colors
  white = color(255, 255, 255);
  black = color(0, 0, 0);
  green = color(0, 255, 0);

  //Cameras and Color trackers
  String camName = "name=USB Camera,size=1280x960,fps=30";
  String camName1 = "name=USB Camera #2,size=1280x960,fps=30";
  cam = new Capture(this, camName);
  cam1 = new Capture(this, camName1);
  xy = new Tracker(15, cam, camName);
  yz = new Tracker(10, cam1, camName1);

  //Server
  server = new Server(this, 5787);
}

/* 
 * List available cameras, exit if there are none
 */
void listCameras(){
  if(cameras.length == 0){
    println("There are no cameras available for capture.");
    exit();
  }
  else{
    println("Available cameras:");
    for(int i = 0; i < cameras.length; i++){
      println(i + ":" + cameras[i]);
    }
  }
}

/*******************/
/*      SETUP      */
/*******************/

/* 
 * Initialize, print out list of cameras, etc.
 */
void setup(){
  //Set the size of the rendering
  size(1280, 720);
  println("DONE SETTING SIZE");

  //List cameras
  cameras = Capture.list();
  listCameras();
  println("DONE LISTING CAMERAS");

  //Get variables and objects ready
  initialize();
  println("DONE INITIALIZING");

  //Set rendering colors
  noFill();
  stroke(green);
  strokeWeight(2);
  background(black);
  println("DONE SETTING RENDERING COLORS");

  println("RUNNING draw()");
}

/*******************/
/*      DRAW       */
/*******************/

/* 
 * Update all information and serve it, display averages
 */
void draw(){
  Client client = server.available();

  //In configuration mode, configure the trackers
  if(xy.confMode || yz.confMode){
    if(xy.confMode){
      xy.update();
    }
    else if(yz.confMode){
      yz.update();
    }
  }

  //No longer in configuration mode, run the application
  else{
    //If both trackers have new information
    if(xy.updated && yz.updated){
      //Get all 3 coordinates
      float x = xy.getRatios()[0];
      float y = xy.getRatios()[1];
      float z = yz.getRatios()[0] * -1;
 
      //Send packet
      server.write(x + "," + y + "," + z + ";");

      //Reset updated status of the trackers
      xy.updated = false;
      yz.updated = false;

      //Reset debug rendering
      background(black);

      //Debug output
      println(x, y, z);
      image(cam, 0, height / 4, width / 2, height / 2);
      image(cam1, width / 2, height / 4, width / 2, height / 2);

      //Update again
      xy.update();
      yz.update();
    }
    //If either tracker does not have new information
    else{
      xy.update();
      yz.update();
    }
    rect(((xy.getRatios()[0] * width) / 2) - 15, ((xy.getRatios()[1] * height) / 2) + (height / 4) - 15, 30, 30);
    rect((((yz.getRatios()[0] * width) / 2) + (width / 2)) - 15, ((yz.getRatios()[1] * height) / 2) + (height / 4)  - 15, 30, 30);
  }
}

/*******************/
/*    HANDLERS     */
/*******************/

/* 
 * Send coordinates from the mouse press to the Tracker object being configured
 * Does nothing unless in configuration mode
 */
void mousePressed(){
  if(xy.confMode == true){
    xy.addColor();
  }
  else if(yz.confMode == true){
    yz.addColor();
  }
}

/* 
 * Increment keysPressed
 * Cycle through Tracker objects each time a key is pressed until all Tracker objects are configured
 * When a Tracker has been configured, disable configuration mode
 */
void keyPressed(){
  if(xy.confMode == true){
    xy.confMode = false;
    println("CONFIGURING SECOND CAMERA");
  }
  else if(yz.confMode == true){
    yz.confMode = false;
    println("CONFIGURATION COMPlETE");
  }
}
