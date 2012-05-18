// Testing try with  both catch and finally clause

public class try_catch_finally {

  public static void main(String[] args) {
    try {
      try {
        System.out.println("no exception first time");
      } catch (RuntimeException e3) {
        System.out.println("caught exception: "+e3.toString());
      } finally {
        System.out.println("finally after no exception");
      }

      if(true) throw new RuntimeException("");

      System.out.println("No exception second time");
    } catch (RuntimeException e3) {
      System.out.println("caught exception: " + e3.toString());
    } finally {
      System.out.println("finally after exception");
    }
    System.out.println("Done!");
  }
}

// no exception first time
// finally after no exception
// caught exception: java.lang.RuntimeException:
// finally after exception
// Done!
