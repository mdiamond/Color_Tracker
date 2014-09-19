/* 
 * Matthew Diamond 2014
 * A color tracker to track the color provided on either the (x, y) or (y, z) coordinates
 * If attempting to track 3 coordinates, two Tracker objects must be used
 */
class Tracker{

  //Camera to capture from 
  Capture cam;
  //Camera name
  String camName;
  //Coordinates
  float[] coordinates;
  //Colors to be tracked
  float[][] targetColors;
  //Sensitivity: lower will select fewer pixels
  int trackingSensitivity;
  //Number of pixels matched
  int numPixels;
  //Number of colors being tracked
  int numColors;
  //Number of times in a row the camera has been unavailable
  int u;
  //Configuring or not?
  boolean confMode;
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
    //Fill targetColors with dummy data
    for(int i = 0; i < targetColors.length; i++){
      targetColors[i] = new float[3];
      for(int j = 0; j < 3; j++){
        targetColors[i][j] = -1.0;
      }
    }

    //ints
    trackingSensitivity = trackingSensitivity1;
    numPixels = 0;
    numColors = 0;
    u = 0;

    //booleans
    confMode = true;
    everAvailable = false;
    updated = false;

    //Prepare the camera for capture
    cam.start();
  }

  /*
   * Helper method for update() ...
   * Scan the image for a color one time given its index in the array of target colors
   */
  void scanPixels(int c){
    //For each pixel in the image, compare it to the target color
    for(int x = 0; x < cam.width; x ++){
      for(int y = 0; y < cam.height; y ++){

        //Get color of the current pixel as r, g and b
        int loc = x + y*cam.width;
        color currentColor = cam.pixels[loc];
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
  void update(){
    //Check if the camera is available and keep track of how many times it isn't
    u += 1;
    if(cam.available()){
      cam.read();
      u = 0;
      updated = true;
    }

    //Display the video feed at the size of the window if configuring
    if(confMode){
      image(cam, 0, 0, width, height);
    }

    //Set up average location of the tracked colors as [x, y] or [y, z]
    coordinates[0] = 0;
    coordinates[1] = 0;
    numPixels = 0;

    //Add up pixel locations
    for(int c = 0; c < targetColors.length && targetColors[c][1] != -1.0; c ++){
      scanPixels(c);
    }

    //Calculate average x and y locations
    if(numPixels != 0){
      coordinates[0] /= numPixels;
      coordinates[1] /= numPixels;
    }

     //Display visual feedback on configuration that shows the averaged location of the tracked colors as you add them
    if(confMode){
      rect((((coordinates[0] / cam.width) * width) - 15), (((coordinates[1] / cam.height) * height)  - 15), 30, 30);
    }

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
   * Return the coordinates
   */
  float[] getCoordinates(){
    float[] result = new float[2];
    result[0] = coordinates[0];
    result[1] = coordinates[1];

    return result;
  }
  
  /* 
   * Get the coordinate ratios ...
   * Return the coordinates as a x:1 ratio so it is scalable to any size rendering
   */
  float[] getRatios(){
    float[] result = new float[2];
    result[0] = coordinates[0] / cam.width;
    result[1] = coordinates[1] / cam.height;

    return result;
  }

  /* 
   * Add a new color to track ...
   * Determines the location of the mouse, the color at that location, and then store the color
   */
  void addColor(){
    //Calculate the x:1 ratio of the x and y locations clicked
    float xRatio = (float) mouseX / width;
    float yRatio = (float) mouseY / height;

    //Calculate the location in the image that is at the ratio calculated
    int x = (int) (xRatio * cam.width);
    int y = (int) (yRatio * cam.height);

    //Get the color at that location
    color c = cam.get(x, y);

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
