/* 
 * Matthew Diamond 2014
 * A record of (x, y, z) coordinates
 */
class Trace{

  //A list of sets of coordinates
  ArrayList<Coordinates> coordinates;

  /* 
   * Constructor for the Trace object ...
   * Initializes the list
   */
  Trace(){
    coordinates = new ArrayList<Coordinates>();
  }

  /* 
   * Adds a new set of coordinates to the list
   */
  void update(Coordinates c){
    coordinates.add(c);
  }

  /*
   * Renders the full trace from first coordinate to last as a single line
   */
  void render(){
    if(coordinates.size() > 1){
      for(int i = 1; i < coordinates.size(); i ++){
        line(coordinates.get(i - 1).x, coordinates.get(i - 1).y, coordinates.get(i - 1).z, coordinates.get(i).x, coordinates.get(i).y, coordinates.get(i).z);
        translate(coordinates.get(i).x, coordinates.get(i).y, coordinates.get(i).z);
        sphere(1);
        translate(coordinates.get(i).x * -1, coordinates.get(i).y * -1, coordinates.get(i).z * -1);

      }
    }
  }

}
