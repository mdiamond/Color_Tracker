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

public class Color_Tracker_Client extends PApplet {

/* 
 * Matthew Diamond 2014
 */




//Screen resolution
int resX;
int resY;
int resZ;
//Colors
int black;
int white;
//The Tank object
Tank fishTank;
//The Fish oject
Fish notCarl;
//Client
Client client;
//x, y, z
float x;
float y;
float z;
//Variables representing whether or not x, y, z have all been updated
boolean xU;
boolean yU;
boolean zU;

/*******************/
/*     HELPERS     */
/*******************/

/* 
 * Initialize all major objects and variables
 */
public void initialize(){
  //Screen resolution
  resX = 1364;
  resY = 766;
  resZ = 500;

  //x, y, z
  x = 0;
  y = 0;
  z = 0;

  //x, y, z updated booleans
  xU = false;
  yU = false;
  zU = false;
  
  //Colors
  black = color(0, 0, 0);
  white = color(255, 255, 255);

  //Tank
  fishTank = new Tank(width / 2, height / 2, ((resX * -1) / 2) - 200, resX, resY, resZ);
  //Fish
  notCarl = new Fish(width / 2, height / 2, -200);

  client = new Client(this, "127.0.0.1", 5787);

}

/*******************/
/*      SETUP      */
/*******************/

/* 
 * Initialize, print out list of cameras, etc.
 */
public void setup(){
  //Set the size of the rendering
  size(1364, 766, P3D);
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
public void draw(){
  background(black);

  if(client.available() > 0 && xU == false){
    x = client.read() / 10000.0f;
    xU = true;
  }
  if(client.available() > 0 && yU == false){
    y = client.read() / 10000.0f;
    yU = true;
  }
  if(client.available() > 0 && zU == false){
    z = client.read() / 10000.0f;
    zU = true;
  }

  if(xU && yU && zU);
    //Update and render
    notCarl.update((int) (x * resX), (int) (y * resY), (int) ((z * resZ) - 200));
    notCarl.render();
    fishTank.render();
    xU = false;
    yU = false;
    zU = false;
}
/* 
 * Matthew Diamond 2014
 * A fish as an (x, y, z) coordinate
 */
class Fish{

  //Location coordinates
  int x;
  int y;
  int z;

  /* 
   * Constructor for the Fish object ...
   * Sets up the initial (x, y, z) location of the fish
   */
  Fish(int x1, int y1, int z1){
    x = x1;
    y = y1;
    z = z1;
  }

  /* 
   * Update the fish ...
   * Updates the (x, y, z) coordinates of the fish
   */
  public void update(int x1, int y1, int z1){
    x = x1;
    y = y1;
    z = z1;
  }

  /* 
   * Render the fish ...
   * Renders the fish as a sphere
   */
  public void render(){
    translate(x, y, z);
    sphere(25);
    translate(x * -1, y * -1, z * -1);
  }

}
/* 
 * Matthew Diamond 2014
 * The tank as a cube of size (x, y, z) at location (x, y, z)
 */
class Tank{

  //Location coordinates
  int x;
  int y;
  int z;
  //Size coordinates
  int sizeX;
  int sizeY;
  int sizeZ;

  /* 
   * Constructor for the Tank object ...
   * Sets up the location and size of the tank
   */
  Tank(int x1, int y1, int z1, int sizeX1, int sizeY1, int sizeZ1){
    x = x1;
    y = y1;
    z = z1;
    sizeX = sizeX1;
    sizeY = sizeY1;
    sizeZ = sizeZ1;
  }

  /* 
   * Render the tank ...
   * Renders the tank
   */
  public void render(){
    translate(x, y, z);
    box(sizeX, sizeY, sizeZ);
    translate(x * -1, y * -1, z * -1);
  }

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Color_Tracker_Client" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
