/* 
 * A color tracker to track the color provided on either the (x, y) or (y, z) coordinates
 * Needs the camera number, target color, and tracking sensitivity level
 * If attempting to track 3 coordinates, two Tracker objects must be used
 */
class Tracker{

  //Coordinates
  float[] coordinates;
  //The camera to capture from 
  Capture cam; 
  //The color to be tracked
  color targetColor;
  //Sensitivity: lower will select fewer pixels
  int trackingSensitivity;
  //Number of pixels being tracked
  int n;
  //Number of times the coordinates have been requested
  int t;
  //Camera number
  int camNumber;
  //Color to compare to as r, g and b
  float r2;
  float g2;
  float b2;

  /* 
   * Constructor for the Tracker object ...
   * Sets up the tracker
   */
  Tracker(Goldfish_Tracker that, int camNumber1, color targetColor1, int trackingSensitivity1){
    coordinates = new float[2];
    cam = new Capture(that, cameras[camNumber]);
    targetColor = targetColor1;
    trackingSensitivity = trackingSensitivity1;
    n = 0;
    t = 0;
    camNumber = camNumber1;
    r2 = red(targetColor);
    g2 = green(targetColor);
    b2 = blue(targetColor);

    cam.start();
  }

  /* 
   * Update the coordinates of the tracked color ...
   * Matches pixel colors and averages matched locations to decide where the object is
   */
  void update(){
    if(cam.available()){

      cam.read();
      //Set up average location of the tracked color
      coordinates[0] = 0;
      coordinates[1] = 0;
      //How many pixels matched
      n = 0;

      //For each pixel in the image, compare it to the target color
      for(int x = 0; x < cam.width; x ++){
        for(int y = 0; y < cam.height; y ++){
          //Get color of the current pixel as r, g and b
          int loc = x + y*cam.width;
          color currentColor = cam.pixels[loc];
          float r1 = red(currentColor);
          float g1 = green(currentColor);
          float b1 = blue(currentColor);
          //Euclidian distance
          float d = dist(r1,g1,b1,r2,g2,b2);

          //Check if it is close enough to the target color
          if(d < trackingSensitivity)
          {
            //Add to the total x and y values
            coordinates[0] += x;
            coordinates[1] += y;
            n += 1;
          }

        }
      }

      //Calculate average x and y locations
      if(n != 0){
        coordinates[0] /= n;
        coordinates[1] /= n;
      }

    }
  }

  /*
   * Get the coordinates ...
   * Return the coordinates as a x:1 so it is scalable to any size rendering
   */
  float[] get_coordinates(){
    float[] result = new float[2];
    result[0] = coordinates[0] / cam.width;
    result[1] = coordinates[1] / cam.height;
    if(t % 30 == 0){
      println(result[0], result[1], n);
    }
    t++;
    return result;
  }

}
