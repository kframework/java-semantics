public class return_05_if_then_else {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    System.out.println("f(true) = " + f(true));
    System.out.println("f(false) = " + f(false));
  }

  int f(boolean b) {
    if (b) {
      return 3;
    } else {
      return 4;
    }
  }
}
