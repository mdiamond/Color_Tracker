/* 
 * Matthew Diamond 2014
 */

import processing.video.*;
import processing.net.*;

//Screen resolution
int resX;
int resY;
int resZ;
//Colors
color black;
color white;
//The Tank object
Tank fishTank;
//The Fish oject
Fish notCarl;
//Client
Client client;
//x, y, z
int x;
int y;
int z;
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
void initialize(){
  //Screen resolution
  resX = 700;
  resY = 500;
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
void setup(){
  //Set the size of the rendering
  size(700, 500, P3D);
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
  background(black);

  if(xU == false && client.available() > 0){
    x = client.read();
    xU = true;
  }
  if(yU == false && xU == true && client.available() > 0){
    y = client.read();
    yU = true;
  }
  if(zU == false && xU == true && yU == true && client.available() > 0){
    z = client.read();
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
    println(x, y, z);
}
