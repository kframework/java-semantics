// Testing try with  both catch and finally clause, no exception

public class throw_13_try_CF_no_throw {

  public static void main(String[] args) {
    try {
      System.out.println("no exception");
    } catch (RuntimeException e3) {
      System.out.println("caught exception: " + e3.toString());
    } finally {
      System.out.println("finally after no exception");
    }
    System.out.println("Done!");
  }
}

