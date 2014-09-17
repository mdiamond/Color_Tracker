/* 
 * Matthew Diamond 2014
 */

import processing.video.*;
import processing.net.*;

//The number of times any key has been pressed
int keysPressed;
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
//Coordinates that could not be written out yet
ArrayList<String> notWritten;
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

  //Colors
  white = color(255, 255, 255);
  black = color(0, 0, 0);

  //Cameras and Color trackers
  String camName = "name=USB Camera,size=1280x960,fps=30";
  String camName1 = "name=USB Camera #2,size=1280x960,fps=30";
  cam = new Capture(this, camName);
  cam1 = new Capture(this, camName1);
  xy = new Tracker(15, cam, camName);
  yz = new Tracker(10, cam1, camName1);

  //Leftover coordinates
  notWritten = new ArrayList<String>();

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
  stroke(black);
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
      float x = xy.getCoordinates()[0];
      float y = xy.getCoordinates()[1];
      float z = yz.getCoordinates()[0] * -1;
 
      //Serve the most up to date coordinates if the server is available
      if(server.available()){
        //If there are leftover unwritten coordinates
        if(notWritten.size() > 0){
          server.write(notWritten.get(0));
          notWritten.remove(0);
        }
        //If there are no leftover coordinates
        else{
          server.write(x + "," + y + "," + z);

          //Reset debug rendering
          background(black);

          //Debug output
          println(x, y, z);
          image(cam, 0, height / 4, width / 2, height / 2);
          image(cam1, width / 2, height / 4, width / 2, height / 2);
        }
      }
      //Keep track of the coordinates that couldn't be sent
      else{
        notWritten.add(x + "," + y + "," + z);
      }
      //Reset updated status of the trackers
      xy.updated = false;
      yz.updated = false

      //Update again
      xy.update();
      yz.update();
    }
    //If either tracker does not have new information
    else{
      xy.update();
      yz.update();
    }
    rect((((xy.coordinates[0] / cam.width) * width) - 7) / 2, ((((xy.coordinates[1] / cam.height) * height)  - 7) / 2) + height / 4, 15, 15);
    rect(((((yz.coordinates[0] / cam1.width) * width) - 7) / 2) + width / 2, (((yz.coordinates[1] / cam1.height) * height)  - 7), 15, 15);
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
