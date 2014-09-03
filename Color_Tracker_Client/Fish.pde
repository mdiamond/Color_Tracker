/* 
 * Matthew Diamond 2014
 * A fish as an (x, y, z) coordinate
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
   * Update the fish ...
   * Updates the (x, y, z) coordinates of the fish
   */
  void update(int x1, int y1, int z1){
    x = x1;
    y = y1;
    z = z1;
  }

  /* 
   * Render the fish ...
   * Renders the fish as a sphere
   */
  void render(){
    translate(x, y, z);
    sphere(25);
    translate(x * -1, y * -1, z * -1);
  }

}
