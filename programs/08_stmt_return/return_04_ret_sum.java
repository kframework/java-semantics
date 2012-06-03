public class return_04_ret_sum {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    System.out.println("f() = " + f());
  }

  int f() {
    System.out.println("inside f()");
    return 3+4;
  }
}
