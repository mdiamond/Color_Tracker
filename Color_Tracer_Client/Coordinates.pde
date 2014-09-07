/* 
 * Matthew Diamond 2014
 * A set of (x, y, z) coordinates
 */
class Coordinates{

  //The coordinates
  int x;
  int y;
  int z;

  /* 
   * Constructor for the Coordinates object ...
   * Sets the initial (x, y, z) coordinates
   */
  Coordinates(int x1, int y1, int z1){
    x = x1;
    y = y1;
    z = z1;
  }

  /* 
   * Updates the (x, y, z) coordinates
   */
   void update(int x1, int y1, int z1){
    x = x1;
    y = y1;
    z = z1;
  }

}
