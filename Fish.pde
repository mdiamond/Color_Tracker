/* 
 * The fish as an (x, y, z) coordinate when 3D, and an (x, y) coordinate otherwise
 * Needs the number of coordinates appropriate for the number of dimensions desired
 * Use 3D methods if 3D and 2D methods if 2D
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
   * Constructor for the Fish object ...
   * Sets up the initial (x, y) location of the fish
   */
  Fish(int x1, int y1){
    x = x1;
    y = y1;
  }

  /* 
   * Update the fish ...
   * Updates the (x, y, z) coordinates of the fish
   */
  void update3D(int x1, int y1, int z1){
    x = x1;
    y = y1;
    z = z1;
  }

  /* 
   * Update the fish ...
   * Updates the (x, y) coordinates of the fish
   */
  void update2D(int x1, int y1){
    x = x1;
    y = y1;
  }

  /* 
   * Render the fish ...
   * Renders the fish as a sphere
   */
  void render3D(){
    translate(x, y, z);
    sphere(25);
    translate(x * -1, y * -1, z * -1);
  }

  /* 
   * Render the fish ...
   * Render the fish as an ellipse
   */
  void render2D(){
    ellipse(x, y, 40, 25);
  }

}
