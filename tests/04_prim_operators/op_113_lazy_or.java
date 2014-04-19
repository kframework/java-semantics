public class op_113_lazy_or {
  public static void main(String[] args) {
    new main(args);
  }
}

class main {

	main(String[] args) {
    System.out.println("true || false       = " + (true||false));
    System.out.println("false || true       = " + (false||true));
    System.out.println("fTrue() || fFalse() = " + (fTrue()||fFalse()));
    System.out.println("fFalse() || fTrue() = " + (fFalse()||fTrue()));
    System.out.println("Done!");
	}

  boolean fTrue() {
    System.out.println("fTrue()");
    return true;
  }

  boolean fFalse() {
    System.out.println("fFalse()");
    return false;
  }
}
