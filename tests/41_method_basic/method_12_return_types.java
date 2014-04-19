/*
Test method return type. Call a method returning:
  - int, bool, String, RuntimeException, int[].
  - RuntimeException return, converted to Object. (return type conversion)
  - RuntimeException return, ignored. Called using Expression statement.
  Print the result.
*/

public class method_12_return_types {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    System.out.println(fInt());
    System.out.println(fBool());
    System.out.println(fString());
    System.out.println(fRE("re"));
    System.out.println(fVInt()[0]+" "+fVInt()[1]);

    Object o = fRE("obj re");
    fRE("ignored re");
  }

  int fInt() {
    return 18;
  }

  boolean fBool() {
    return true;
  }

  String fString() {
    return "abc";
  }

  RuntimeException fRE(String s) {
    System.out.println("fRE(" +s+")");
    return new RuntimeException(s);
  }

  int[] fVInt() {
    int[] v = new int[2];
    v[0] = 11;
    v[1] = 22;
    return v;
  }
}
