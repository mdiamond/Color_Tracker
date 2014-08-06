import processing.video.*;

//3D or not?
boolean threeD;
//Size of the tank in pixels
int tankSize;
//Colors
color black;
color white;
color red;
color green;
color blue;
color targetColorXY; //The colors to be tracked by the trackers
color targetColorYZ;
//The Tank object
Tank fishTank;
//The Fish oject
Fish notCarl;
//The color trackers
Tracker xy;
Tracker yz;
//A list of the cameras available for use
String[] cameras;

/* 
 * Initialize all major objects and variables
 */
void initialize(){
  threeD = false; //3D or not?
  tankSize = 700;
  black = color(0, 0, 0);
  white = color(255, 255, 255);
  red = color(255, 0, 0);
  green = color(0, 255, 0);
  blue = color(0, 255, 0);
  targetColorXY = white; // color(88, 113, 86);
  fishTank = new Tank(width / 2, height / 2, -350, tankSize, tankSize, tankSize);
  notCarl = new Fish(width / 2, height / 2, 0);
  cameras = Capture.list();
  xy = new Tracker(this, 15, targetColorXY, 50);
  if(threeD){ //3D means another color to track, another Tracker object, and rotation
    targetColorYZ = black; // color(88, 13, 86);
    yz = new Tracker(this, 15, targetColorYZ, 50);
  }
}

/* 
 * Initialize, print out list of cameras, etc.
 */
void setup(){
  initialize();

  //Show camera selection
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

  //Set the size of the rendering
  if(threeD){
    size(tankSize, tankSize, P3D);
  }
  else{
    size(tankSize, tankSize);
  }

  //Set rendering colors
  stroke(white);
  noFill();
  background(black);
}

/* 
 * Update all information and render
 */
void draw(){
  background(black);
  xy.update();
  float x = xy.get_coordinates()[0] * fishTank.sizeX;
  float y = xy.get_coordinates()[1] * fishTank.sizeY;
  if(threeD){
    yz.update();
    float z = yz.get_coordinates()[0] * fishTank.sizeZ;
    notCarl.update3D((int) x, (int) y, (int) z);
    notCarl.render3D();
    fishTank.render3D();
  }
  else{
    notCarl.update2D((int) x, (int) y);
    notCarl.render2D();
    fishTank.render2D();
  }
}
