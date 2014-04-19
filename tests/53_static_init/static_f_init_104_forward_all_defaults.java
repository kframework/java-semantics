/*
Fields with initializer, forward reference, default values for all types tested.
*/

class A {

  static Vals vals = new Vals();
  static String defaultVals = getValues();

  static byte b = vals.b;
  static short s = vals.s;
  static int i = vals.i;
  static long l = vals.l;
  static char ch = vals.ch;
  static boolean bool = vals.bool;
  static String str = vals.str;
  static Object o = vals.o;

  static String initializedVals = getValues();

  static String getValues() {
    return "" + b + " " + s + " " + i + " " + l + " " + ch + " " + bool + " " + str + " " + o;
  }
}

class Vals {
  byte b = 1;
  short s = 2;
  int i = 3;
  long l = 4;
  char ch = 'x';
  boolean bool = true;
  String str = "abc";
  Object o = new RuntimeException("re");
}

public class static_f_init_104_forward_all_defaults {
  public static void main(String[] args) {
    System.out.println(A.defaultVals);
    System.out.println(A.initializedVals);
    System.out.println("Done!");
  }
}
