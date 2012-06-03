class Ex extends RuntimeException {
  Ex(String s) {
    super(s);
  }
}

public class return_15_ret_ref_derived {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    System.out.println("f() = " + f());
  }

  RuntimeException f() {
    return new Ex("abc");
  }
}
