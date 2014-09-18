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
color red;
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
  resX = 1280;
  resY = 720;
  resZ = 600;

  //Colors
  black = color(0, 0, 0);
  white = color(255, 255, 255);
  red = color(255, 0, 0);

  //Trace
  trace = new Trace();

  //Viewpoint camera
  cam = new PeasyCam(this, resX, resY, resZ * -1, 3000);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(3000);

  //Client
  client = new Client(this, "192.168.0.100", 5787);
}

boolean sketchFullScreen() {
  return true;
}

/*******************/
/*      SETUP      */
/*******************/

/* 
 * Initialize, print out list of cameras, etc.
 */
void setup(){
  //Set the size of the rendering
  size(1280, 720, P3D);
  println("DONE SETTING SIZE");

  //Get variables and objects ready
  initialize();
  println("DONE INITIALIZING");

  //Set rendering colors
  smooth();
  stroke(white);
  strokeWeight(3);
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
  String clientString;

  if(client.available() > 0){
    clientString = client.readStringUntil(';');
    if(clientString != null){
      clientString = clientString.substring(0, clientString.length() - 1);
      ratios = float(split(clientString, ","));

      if(ratios.length == 3){
        //Calculate the coordinates relative to our 3D space
        coordinates[0] = (int) (ratios[0] * resX * 2);
        coordinates[1] = (int) (ratios[1] * resY * 2);
        coordinates[2] = (int) (ratios[2] * resZ * 2);

        //Add a new set of coordinates to the trace
        trace.update(new Coordinates(coordinates[0], coordinates[1], coordinates[2]));

        //Print coordinates that were added
        println(coordinates[0], coordinates[1], coordinates[2]);
      }
    }
  }

  //Reset rendering, re-render, print coordinates
  background(black);
  trace.render();
}
