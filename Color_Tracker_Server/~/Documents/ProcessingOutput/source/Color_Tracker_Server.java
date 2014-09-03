import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import processing.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Color_Tracker_Server extends PApplet {

/* 
 * Matthew Diamond 2014
 */




//The number of times any key has been pressed
int keysPressed;
//Size
int size;
//Colors
int white;
int black;
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
public void initialize(){

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
public void listCameras(){
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
public void setup(){
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
public void draw(){
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
      float x = xy.getCoordinates()[0] * 10000;
      float y = xy.getCoordinates()[1] * 10000;

      //Get the coordinates from the second tracker
      yz.update();
      float z = (yz.getCoordinates()[0] * 10000) * -1;

      //Send packet
      server.write((int) x);
      server.write((int) y);
      server.write((int) z);

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
public void mousePressed(){
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
public void keyPressed(){
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
/* 
 * Matthew Diamond 2014
 * A color tracker to track the color provided on either the (x, y) or (y, z) coordinates
 * If attempting to track 3 coordinates, two Tracker objects must be used
 */
class Tracker{

  //Coordinates
  float[] coordinates;
  //Camera to capture from 
  Capture cam;
  //Colors to be tracked
  float[][] targetColors;
  //Sensitivity: lower will select fewer pixels
  int trackingSensitivity;
  //Number of pixels matched
  int numPixels;
  //Number of colors being tracked
  int numColors;
  //Number of times the coordinates have been requested
  int t;
  //Number of times in a row the camera has been unavailable
  int u;
  //Camera number
  int camNumber;
  //Configuring or not?
  boolean confMode;
  //Camera name
  String camName;
  //Was this camera ever available?
  boolean everAvailable;
  //Whether or not an updated tracking is available
  boolean updated;

  /* 
   * Constructor for the Tracker object ...
   * Sets up the tracker
   */
  Tracker(int trackingSensitivity1, Capture cam1, String camName1){
    cam = cam1;
    camName = camName1;
    coordinates = new float[2];
    targetColors = new float[8][];
    for(int i = 0; i < targetColors.length; i++){
      targetColors[i] = new float[3];
      for(int j = 0; j < 3; j++){
        targetColors[i][j] = -1.0f;
      }
    }
    trackingSensitivity = trackingSensitivity1;
    numPixels = 0;
    numColors = 0;
    t = 0;
    u = 0;
    confMode = true;
    everAvailable = false;
    updated = true;

    cam.start();
  }

  /*
   * Helper method for update() ...
   * Scan the image for a color one time given its index in the array of target colors
   */
  public void scanPixels(int c){
    //For each pixel in the image, compare it to the target color
    for(int x = 0; x < cam.width; x ++){
      for(int y = 0; y < cam.height; y ++){

        //Get color of the current pixel as r, g and b
        int loc = x + y*cam.width;
        int currentColor = cam.pixels[loc];
        float r1 = red(currentColor);
        float g1 = green(currentColor);
        float b1 = blue(currentColor);

        //Euclidean distance
        float d = dist(r1, g1, b1, targetColors[c][0], targetColors[c][1], targetColors[c][2]);

        //Check if it is close enough to the target color
        if(d < trackingSensitivity){
          //Allows visual feedback on selection of colors to track
          if(confMode){
            set((int) ((x / (float) cam.width) * width), (int) ((y / (float) cam.height) * height), white);
          }
          //Add to the total x and y values
          coordinates[0] += x;
          coordinates[1] += y;
          numPixels += 1;
        }
      }
    }
  }

  /* 
   * Update the coordinates of the tracked color ...
   * Matches pixel colors and averages matched locations to decide where the object is
   */
  public void update(){
    u += 1;
    if(cam.available()){
      cam.read();
      u = 0;
      updated = true;
    }

    if(confMode){
      image(cam, 0, 0, width, height);
    }

    //Set up average location of the tracked colors as [x, y] or [y, z]
    coordinates[0] = 0;
    coordinates[1] = 0;
    numPixels = 0;

    //Add up pixel locations
    for(int c = 0; c < targetColors.length && targetColors[c][1] != -1.0f; c ++){
      scanPixels(c);
    }

    //Calculate average x and y locations
    if(numPixels != 0){
      coordinates[0] /= numPixels;
      coordinates[1] /= numPixels;
    }

    //Allows visual feedback on selection of colors to track
    rect((((coordinates[0] / cam.width) * width) - 15), (((coordinates[1] / cam.height) * height)  - 15), 30, 30);

    //If the camera is unavailable 200 times in a row
    if(u == 200){
      println("CAMERA " + camName + " NOT AVAILABLE 200 TIMES IN A ROW. EXITING.");
      exit();
    }

    else if(u > 0){
      //println("CAMERA " + camName + " NOT AVAILABLE " + u + " TIME(S)");
    }
  }

  /* 
   * Get the coordinates ...
   * Return the coordinates as a x:1 ratio so it is scalable to any size rendering
   */
  public float[] getCoordinates(){
    float[] result = new float[2];
    result[0] = coordinates[0] / cam.width;
    result[1] = coordinates[1] / cam.height;
    if(t % 30 == 0){
      println(result[0], result[1], numPixels);
    }
    t++;
    return result;
  }

  /* 
   * Add a new color to track ...
   * Determines the location of the mouse, the color at that location, and then store the color
   */
  public void addColor(){
    //Calculate the x:1 ratio of the x and y locations clicked
    float xRatio = (float) mouseX / width;
    float yRatio = (float) mouseY / height;

    //Calculate the location in the image that is at the ratio calculated
    int x = (int) (xRatio * cam.width);
    int y = (int) (yRatio * cam.height);

    //Get the color at that location
    int c = cam.get(x, y);

    //Separate the color into r, g, and b
    float r = red(c);
    float g = green(c);
    float b = blue(c);

    //Get the color that was clicked, add it to the array of colors to track
    if(numColors < targetColors.length){
      targetColors[numColors][0] = r;
      targetColors[numColors][1] = g;
      targetColors[numColors][2] = b;
      numColors ++;
      if(numColors <= targetColors.length){
        println("COLOR ADDED");
      }
      if(numColors >= targetColors.length){
        println("NOW TRACKING THE MAXIMUM NUMBER OF COLORS");
      }
    }
    else{
      println("ALREADY TRACKING THE MAXIMUM NUMBER OF COLORS");
    }
  }

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Color_Tracker_Server" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
