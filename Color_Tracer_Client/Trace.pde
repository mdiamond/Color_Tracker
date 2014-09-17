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
    if(coordinates.size() > 4){
      float percent;
      int num = coordinates.size();
      int alpha;
      beginShape();
      curveVertex(coordinates.get(0).x, coordinates.get(0).y, coordinates.get(0).z);
      for(int i = 0; i < num; i ++){
        percent = i / (float) num;
        alpha = (int) (percent * 255);
        stroke(alpha);
        
        curveVertex(coordinates.get(i).x, coordinates.get(i).y, coordinates.get(i).z);
      }
      curveVertex(coordinates.get(num - 1).x, coordinates.get(num - 1).y, coordinates.get(num - 1).z);
      endShape();
      
      translate(coordinates.get(num - 1).x, coordinates.get(num - 1).y, coordinates.get(num - 1).z);
      stroke(red);
      sphere(10);
      translate(coordinates.get(num - 1).x * -1, coordinates.get(num - 1).y * -1, coordinates.get(num - 1).z * -1);
    }
  }

}
