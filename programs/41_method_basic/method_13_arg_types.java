/*
Testing method arguments:
  - int, bool, String, RuntimeException, int[].
  Print the arg inside method.
*/

public class method_13_arg_types {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    System.out.println(fInt(12));
    System.out.println(fBool(false));
    System.out.println(fString("abc"));
    System.out.println(fRE(new RuntimeException("big re")));

    int[] v = new int[2];
    v[0] = 100;
    v[1] = 101;
    fVInt(v);
  }

  int fInt(int a) {
    System.out.println(a);
    return a;
  }

  boolean fBool(boolean a) {
    System.out.println(a);
    return a;
  }

  String fString(String a) {
    System.out.println(a);
    return a;
  }

  RuntimeException fRE(RuntimeException a) {
    System.out.println(a);
    return a;
  }

  int[] fVInt(int[] v) {
    for(int i=0; i<v.length; i++) {
      System.out.print(v[i] + " ");
    }
    System.out.println();
    return v;
  }
}
