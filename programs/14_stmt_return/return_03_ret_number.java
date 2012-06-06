public class return_03_ret_number {

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
    return 80;
  }
}
