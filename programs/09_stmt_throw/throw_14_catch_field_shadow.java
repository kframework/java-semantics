// Testing that exception propagates through method calls

class test {

  RuntimeException e = new RuntimeException("field");

  test() {
    try {
      throw new RuntimeException("thrown");
    } catch (RuntimeException e) {
      System.out.println("caught exception: " + e.toString());
    }
    System.out.println(e.toString());
  }
}

public class throw_14_catch_field_shadow {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

