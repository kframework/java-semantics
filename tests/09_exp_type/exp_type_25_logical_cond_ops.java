/*
Conditional and/or: && ||
boolean fTrue() {} boolean fFalse() {} - with side effects
fTrue() && fFalse() : fTrue() && fTrue()
fTrue() || fFalse() : fTrue() || fTrue()
*/

public class exp_type_25_logical_cond_ops {
  public static void main(String[] args) {
     boolean b = true; boolean a = false;

    System.out.println("f(true  ? fFalse() && fTrue() : fTrue() && fTrue()): " + f(true  ? fFalse() && fTrue() : fTrue() && fTrue()));
    System.out.println("f(false ? fFalse() && fTrue() : fTrue() && fTrue()): " + f(false ? fFalse() && fTrue() : fTrue() && fTrue()));
    System.out.println("f(true  ? fFalse() || fFalse() : fTrue() || fFalse()): " + f(true  ? fFalse() || fFalse() : fTrue() || fFalse()));
    System.out.println("f(false ? fFalse() || fFalse() : fTrue() || fFalse()): " + f(false ? fFalse() || fFalse() : fTrue() || fFalse()));

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
    return false;
  }
}
