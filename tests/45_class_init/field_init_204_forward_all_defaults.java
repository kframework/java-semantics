/*
Fields with initializer, forward reference, default values for all types tested.
*/

class A {

  String defaultVals = getValues();

  byte b = 1;
  short s = 2;
  int i = 3;
  long l = 4;
  char ch = 'x';
  boolean bool = true;
  String str = "abc";
  Object o = new RuntimeException("re");

  String initializedVals = getValues();

  String getValues() {
    return "" + b + " " + s + " " + i + " " + l + " " + ch + " " + bool + " " + str + " " + o;
  }
}

public class field_init_204_forward_all_defaults {
  public static void main(String[] args) {
    A a = new A();
    System.out.println(a.defaultVals);
    System.out.println(a.initializedVals);
    System.out.println("Done!");
  }
}
