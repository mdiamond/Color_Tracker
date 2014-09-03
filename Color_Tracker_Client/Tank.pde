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
  void render(){
    translate(x, y, z);
    box(sizeX, sizeY, sizeZ);
    translate(x * -1, y * -1, z * -1);
  }

}
