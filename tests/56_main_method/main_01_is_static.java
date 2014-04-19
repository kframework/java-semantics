/*
Main method is executed in static context. One instance and one static method inside the class.
  One static field - instance counter.
  Call static ones from the static context, all of them from the instance context.
  Test that class counter is 0 before main instantiation, 1 afterwards.
*/

public class main_01_is_static {

  static int count;
  int id;

  public main_01_is_static() {
    System.out.println("main class constructor");
    id = count;
    count++;
  }

  int getId() {
    return id;
  }

  static int getCount() {
    return count;
  }

  public static void main(String[] args) {
    System.out.println("count="+count);
    main_01_is_static mainObj = new main_01_is_static();
    System.out.println("count="+count);
    System.out.println("mainObj.getId()="+mainObj.getId());
    System.out.println("Done!");
  }
}
