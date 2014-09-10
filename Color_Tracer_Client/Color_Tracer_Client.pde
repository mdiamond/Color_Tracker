/* 
 * Matthew Diamond 2014
 */

import processing.video.*;
import processing.net.*;
import peasy.*;

//Screen resolution
int resX;
int resY;
int resZ;
//Colors
color black;
color white;
//Trace object
Trace trace;
//Viewpoint camera
PeasyCam cam;
//Client
Client client;

/*******************/
/*     HELPERS     */
/*******************/

/* 
 * Initialize all major objects and variables
 */
void initialize(){
  //Screen resolution
  resX = 800;
  resY = 600;
  resZ = 600;

  //Colors
  black = color(0, 0, 0);
  white = color(255, 255, 255);

  //Trace
  trace = new Trace();

  //Viewpoint camera
  cam = new PeasyCam(this, resX / 2, resY / 2, (resZ / 2) * -1, 1500);

  //Client
  client = new Client(this, "192.168.0.100", 5787);
}

/*******************/
/*      SETUP      */
/*******************/

/* 
 * Initialize, print out list of cameras, etc.
 */
void setup(){
  //Set the size of the rendering
  size(800, 800, P3D);
  println("DONE SETTING SIZE");

  //Get variables and objects ready
  initialize();
  println("DONE INITIALIZING");

  //Set rendering colors
  stroke(white);
  strokeWeight(15);
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

  float[] ratios;
  int[] coordinates = new int[3];

  if(client.available() > 0){
    ratios = float(split(client.readString(), ","));
    if(ratios.length == 3 && ratios[0] < 1 && ratios[1] < 1 && ratios[2] < 1){
      //Calculate the coordinates relative to our 3D space
      coordinates[0] = (int) (ratios[0] * resX);
      coordinates[1] = (int) (ratios[1] * resY);
      coordinates[2] = (int) (ratios[2] * resZ);

      //Add a new set of coordinates to the trace
      trace.update(new Coordinates(coordinates[0], coordinates[1], coordinates[2]));

      //Reset rendering, re-render, print coordinates
      background(black);
      trace.render();
      println(coordinates[0], coordinates[1], coordinates[2]);
    }
  }
}
