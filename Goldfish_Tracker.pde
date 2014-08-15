import processing.video.*;

//3D or not?
boolean threeD;
//Size of the tank in pixels
int tankSize;
//The number of times any key has been pressed
int keysPressed;
//Colors
color black;
color white;
color red;
color green;
color blue;
//The Tank object
Tank fishTank;
//The Fish oject
Fish notCarl;
//The color trackers
Tracker xy;
Tracker yz;
//A list of the cameras available for use
String[] cameras;

/*******************/
/*     HELPERS     */
/*******************/

/* 
 * Initialize all major objects and variables
 */
void initialize(){
  //3D or not?
  threeD = true;

  //Size of the tank in pixels
  tankSize = 700;
  //The number of times a key has been pressed
  keysPressed = 0;
  
  //Colors
  black = color(0, 0, 0);
  white = color(255, 255, 255);
  red = color(255, 0, 0);
  green = color(0, 255, 0);
  blue = color(0, 0, 255);

  //A list of the cameras available for use
  cameras = Capture.list();

  //Color tracker for (x, y)
  xy = new Tracker(this, 0, 15);
  
  //3D means another color to track, another Tracker object, and rotation
  if(threeD){
    //Objects to render
    fishTank = new Tank(width / 2, height / 2, -350, tankSize, tankSize, tankSize);
    notCarl = new Fish(width / 2, height / 2, 0);

    //Color tracker for (y, z)
    yz = new Tracker(this, 131, 15);
  }
  //2D means different constructors for the Fish and Tank objects, and no need for two Tracker objects or rotation
  else{
    //Objects to render
    fishTank = new Tank(width / 2, height / 2, tankSize - 2, tankSize - 2);
    notCarl = new Fish(width / 2, height / 2);
  }
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

/* 
 * Set the size and 3D-ness of the rendering
 */
void setSize(){
  //3D means an extra argument must be passed to size
//   if(threeD){
//     size(tankSize, tankSize, P3D);
//   }
//   //2D means only x and y dimensions must be specified
//   else{
    size(tankSize, tankSize);
//   }
}

/*******************/
/*      SETUP      */
/*******************/

/* 
 * Initialize, print out list of cameras, etc.
 */
void setup(){
  //Get variables and objects ready
  initialize();

  //Show camera selection
  listCameras();
  
  //Set the size of the rendering
  setSize();

  //Set rendering colors
  stroke(white);
  noFill();
  background(black);
}

/*******************/
/*      DRAW       */
/*******************/

/* 
 * Update all information and render
 */
void draw(){
  //In configuration mode, configure the trackers
  if(xy.confMode || (yz.confMode && threeD)){
    if(xy.confMode){
      xy.updateRender();
    }
    if(threeD && yz.confMode){
      yz.updateRender();
    }
  }

  //No longer in configuration mode, run the application
  else{
    background(black);

    //Get the coordinates from the first tracker
    xy.updateRender();
    float x = xy.getCoordinates()[0] * fishTank.sizeX;
    float y = xy.getCoordinates()[1] * fishTank.sizeY;

    //3D means using the second Tracker object, and calling 3D methods
    if(threeD){
      //Get the coordinates from the second tracker
      yz.updateRender();
      float z = yz.getCoordinates()[0] * fishTank.sizeZ;

      //Update and render
      notCarl.update3D((int) x, (int) y, (int) z);
      notCarl.render3D();
      fishTank.render3D();
    }
    //2D means no second Tracker object, and calling 2D methods
    else{
      //Update and render
      notCarl.update2D((int) x, (int) y);
      notCarl.render2D();
      fishTank.render2D();
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
  else if(keysPressed == 1 && threeD){
    yz.addColor();
  }
}

/* 
 * Increment keysPressed
 * Cycle through Tracker objects each time a key is pressed until all Tracker objects are configured
 * When all Tracker objects have been configured, disable configuration mode
 */
void keyPressed(){
  keysPressed += 1;
  if(keysPressed == 1){
    saveFrame();
    xy.confMode = false;
  }
  else if(keysPressed == 2 && threeD){
    saveFrame();
    yz.confMode = false;
    size(tankSize, tankSize, P3D);
  }
}
