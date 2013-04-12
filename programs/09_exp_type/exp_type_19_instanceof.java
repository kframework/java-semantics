/*
instanceof
B < A
Object o = new A
o instanceof A : o instanceof B
*/

public class exp_type_19_instanceof {
  public static void main(String[] args) {
    Object o = new A();
    System.out.println("f(true  ? o instanceof A : o instanceof B): " + f(true  ? o instanceof A : o instanceof B));
    System.out.println("f(false ? o instanceof A : o instanceof B): " + f(false ? o instanceof A : o instanceof B));
    System.out.println("Done!");
  }

  static String f(boolean b) {
    return "f(boolean): " + b;
  }
}

class A {
  public String toString() {
    return "A";
  }
}

class B extends A {
  public String toString() {
    return "B";
  }
}
