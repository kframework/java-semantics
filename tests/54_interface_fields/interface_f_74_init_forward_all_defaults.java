/*
Fields with initializer, forward reference, default values for all types tested.
*/

interface I1 {

  Vals vals = new Vals();
  String defaultVals = Auxx.getValues();

  byte b = vals.b;
  short s = vals.s;
  int i = vals.i;
  long l = vals.l;
  char ch = vals.ch;
  boolean bool = vals.bool;
  String str = vals.str;
  Object o = vals.o;

  String initializedVals = Auxx.getValues();
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

class Auxx {
  static String getValues() {
    return "" + I1.b + " " + I1.s + " " + I1.i + " " + I1.l + " " + I1.ch + " " + I1.bool
      + " " + I1.str + " " + I1.o;
  }
}

public class interface_f_74_init_forward_all_defaults {
  public static void main(String[] args) {
    System.out.println(I1.defaultVals);
    System.out.println(I1.initializedVals);
    System.out.println("Done!");
  }
}
