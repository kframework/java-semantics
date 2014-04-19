// Testing interplay of fields and catch clause vars with the same name

class ExField extends RuntimeException {}
class ExThrown extends RuntimeException {}

class test {

  RuntimeException e = new ExField();

  test() {
    try {
      throw new ExThrown();
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

