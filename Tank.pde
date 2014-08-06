/* 
 * The tank as a cube of size (x, y, z) at location (x, y, z) if 3D, and as a rectangle of size (x, y) at a particular (x, y) if 2D
 * Needs the number of coordinates appropriate for the number of dimensions desired
 * Use 3D methods if 3D and 2D methods if 2D
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
   * Constructor for the Tank object ...
   * Sets up the location and size of the tank
   */
  Tank(int x1, int y1, int sizeX1, int sizeY1){
    x = x1;
    y = y1;
    sizeX = sizeX1;
    sizeY = sizeY1;
  }

  /* 
   * Render the tank ...
   * Renders the tank
   */
  void render3D(){
    translate(x, y, z);
    box(sizeX, sizeY, sizeZ);
    translate(x * -1, y * -1, z * -1);
  }

  /* 
   * Render the tank ...
   * Renders the tank
   */
  void render2D(){
    rect(1, 1, sizeX, sizeY);
  }

}
