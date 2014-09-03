/* 
 * Matthew Diamond 2014
 */

import processing.video.*;
import processing.net.*;

//The number of times any key has been pressed
int keysPressed;
//Size
int size;
//Colors
color white;
color black;
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

  //Number of keypresses
  keysPressed = 0;

  //Arbitrary size
  size = 700;

  //Colors
  white = color(255, 255, 255);
  black = color(0, 0, 0);

  //Cameras and Color trackers
  String camName = "name=/dev/video1,size=1280x960,fps=15/2";
  String camName1 = "name=/dev/video2,size=640x480,fps=30";
  cam = new Capture(this, camName);
  cam1 = new Capture(this, camName1);
  xy = new Tracker(15, cam, camName);
  yz = new Tracker(15, cam1, camName1);

  cameras = Capture.list();

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
  size(700, 700);
  println("DONE SETTING SIZE");

  //Get variables and objects ready
  initialize();
  println("DONE INITIALIZING");

  //Set rendering colors
  noFill();
  stroke(white);
  background(black);
  println("DONE SETTING RENDERING COLORS");

  //List cameras
  listCameras();
  println("DONE LISTING CAMERAS");

  println("RUNNING draw()");
}

/*******************/
/*      DRAW       */
/*******************/

/* 
 * Update all information and serve it, display averages
 */
void draw(){
  background(black);

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

      //Get the coordinates from the first tracker
      xy.update();
      float x = xy.getCoordinates()[0] * 1000;
      float y = xy.getCoordinates()[1] * 1000;

      //Get the coordinates from the second tracker
      yz.update();
      float z = (yz.getCoordinates()[0] * 1000) * -1;

      //Send packets
      server.write((int) x);
      server.write((int) y);
      server.write((int) z);

      println(x, y, z);
      println((int) x, (int) y, (int) z);

      //Reset updated status of the trackers
      xy.updated = false;
      yz.updated = false;
    }
    else{
      xy.update();
      yz.update();
    }
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
  if(keysPressed == 0){
    xy.addColor();
  }
  else if(keysPressed == 1){
    yz.addColor();
  }
}

/* 
 * Increment keysPressed
 * Cycle through Tracker objects each time a key is pressed until all Tracker objects are configured
 * When a Tracker has been configured, disable configuration mode
 */
void keyPressed(){
  keysPressed += 1;
  if(keysPressed == 1){
    xy.confMode = false;
    println("CONFIGURING SECOND CAMERA");
  }
  else if(keysPressed == 2){
    yz.confMode = false;
    println("CONFIGURATION COMPlETE");
  }
}
