/*
Conditional and/or: && ||
boolean fTrue() {} boolean fFalse() {} - with side effects
fTrue() && fFalse() : fTrue() && fTrue()
fTrue() || fFalse() : fTrue() || fTrue()
*/

public class exp_type_25_logical_cond_ops {
  public static void main(String[] args) {
     boolean b = true; boolean a = false;

    System.out.println("f(true  ? fTrue() && fFalse() : fTrue() && fTrue()): " + f(true  ? fTrue() && fFalse() : fTrue() && fTrue()));
    System.out.println("f(false ? fTrue() && fFalse() : fTrue() && fTrue()): " + f(false ? fTrue() && fFalse() : fTrue() && fTrue()));
    System.out.println("f(true  ? fTrue() || fFalse() : fTrue() || fTrue()): " + f(true  ? fTrue() || fFalse() : fTrue() || fTrue()));
    System.out.println("f(false ? fTrue() || fFalse() : fTrue() || fTrue()): " + f(false ? fTrue() || fFalse() : fTrue() || fTrue()));

    System.out.println("Done!");
  }

  static String f(boolean b) {
    return "f(boolean): " + b;
  }

  static boolean fTrue() {
    System.out.println("fTrue()");
    return true;
  }

  static boolean fFalse() {
    System.out.println("fFalse()");
    return true;
  }
}
