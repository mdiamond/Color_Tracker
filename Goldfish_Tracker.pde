import processing.video.*;

//Screen resolution
int resX;
int resY;
//The number of times any key has been pressed
int keysPressed;
//Colors
color black;
color white;
//The Tank object
Tank fishTank;
//The Fish oject
Fish notCarl;
//The color trackers
Tracker xy;
Tracker yz;
//Cameras for the trackers
Capture cam;
Capture cam1;
//A list of the cameras available for use
String[] cameras;

/*******************/
/*     HELPERS     */
/*******************/

/* 
 * Initialize all major objects and variables
 */
void initialize(){
  //Screen resolution
  resX = 1364;
  resY = 766;
  //The number of times a key has been pressed
  keysPressed = 0;
  
  //Colors
  black = color(0, 0, 0);
  white = color(255, 255, 255);

  //Color trackers
  String camName = "name=/dev/video1,size=1280x960,fps=15/2";
  String camName1 = "name=/dev/video2,size=640x480,fps=30";
  cam = new Capture(this, camName);
  cam1 = new Capture(this, camName1);
  xy = new Tracker(15, cam, camName);
  yz = new Tracker(15, cam1, camName1);

  //Tank
  fishTank = new Tank(width / 2, height / 2, -350, 700, 700, 700);
  //Fish
  notCarl = new Fish(width / 2, height / 2, 0);

}

/*******************/
/*      SETUP      */
/*******************/

/* 
 * Initialize, print out list of cameras, etc.
 */
void setup(){
  //Set the size of the rendering
  size(700, 700, P3D);
  println("DONE SETTING SIZE");

  //Get variables and objects ready
  initialize();
  println("DONE INITIALIZING");

  //Set rendering colors
  stroke(white);
  noFill();
  background(black);
  println("DONE SETTING RENDERING COLORS");

  println("RUNNING draw()");
}

/*******************/
/*      DRAW       */
/*******************/

/* 
 * Update all information and render
 */
void draw(){
  //In configuration mode, configure the trackers
  if(xy.confMode || yz.confMode){
    if(xy.confMode){
      xy.updateRender();
    }
    else if(yz.confMode){
      yz.updateRender();
    }
  }

  //No longer in configuration mode, run the application
  else{
    //If both trackers have new information
    if(xy.updated && yz.updated){
      background(black);

      //Get the coordinates from the first tracker
      xy.updateRender();
      float x = xy.getCoordinates()[0] * fishTank.sizeX;
      float y = xy.getCoordinates()[1] * fishTank.sizeY;

      //Get the coordinates from the second tracker
      yz.updateRender();
      float z = (yz.getCoordinates()[0] * fishTank.sizeZ) * -1;

      //Update and render
      notCarl.update((int) x, (int) y, (int) z);
      notCarl.render();
      fishTank.render();

      //Reset updated status of the trackers
      xy.updated = false;
      yz.updated = false;
    }
    else{
      xy.updateRender();
      yz.updateRender();
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
    saveFrame();
    xy.confMode = false;
    println("CONFIGURING SECOND CAMERA");
  }
  else if(keysPressed == 2){
    saveFrame();
    yz.confMode = false;
    println("CONFIGURATION COMPlETE");
  }
}
