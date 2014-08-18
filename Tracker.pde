/* 
 * A color tracker to track the color provided on either the (x, y) or (y, z) coordinates
 * Needs the camera number, target color, and tracking sensitivity level
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
  //Camera number
  int camNumber;
  //Configuring or not?
  boolean confMode;

  /* 
   * Constructor for the Tracker object ...
   * Sets up the tracker
   */
  Tracker(Goldfish_Tracker that, int camNumber1, int trackingSensitivity1){
    coordinates = new float[2];
    cam = new Capture(that, cameras[camNumber]);
    targetColors = new float[8][];
    for(int i = 0; i < targetColors.length; i++){
      targetColors[i] = new float[3];
      for(int j = 0; j < 3; j++){
        targetColors[i][j] = -1.0;
      }
    }
    trackingSensitivity = trackingSensitivity1;
    numPixels = 0;
    numColors = 0;
    t = 0;
    camNumber = camNumber1;
    confMode = true;

    cam.start();
  }

  /*
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
            set((int) ((x / (float) cam.width) * width),(int) ((y / (float) cam.height) * height), white);
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
  void updateRender(){
    if(cam.available()){
      cam.read();
      if(confMode){
        image(cam, 0, 0, width, height);
      }

      //Set up average location of the tracked colors as [x, y] or [y, z]
      coordinates[0] = 0;
      coordinates[1] = 0;
      numPixels = 0;

      for(int c = 0; c < targetColors.length && targetColors[c][1] != -1.0; c ++){
        //Calculate averages
        scanPixels(c);
      }

      //Calculate average x and y locations
      if(numPixels != 0){
        coordinates[0] /= numPixels;
        coordinates[1] /= numPixels;
      }

      //Allows visual feedback on selection of colors to track
      if(confMode){
        rect((((coordinates[0] / cam.width) * width) - 15), (((coordinates[1] / cam.height) * height)  - 15), 30, 30);
      }
    }

    //If the camera's unavailable
    else if(t % 30 == 0){
      // println("Camera " + camNumber + " is unavailable");
    }
  }

  /*
   * Get the coordinates ...
   * Return the coordinates as a x:1 ratio so it is scalable to any size rendering
   */
  float[] getCoordinates(){
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
        println("Color added");
      }
      if(numColors >= targetColors.length){
        println("Now tracking the maximum number of colors");
      }
    }
    else{
      println("Already tracking the maximum number of colors");
    }
  }

}
