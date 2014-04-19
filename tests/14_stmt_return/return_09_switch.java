//return in switch

public class return_09_switch {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    System.out.println("isPrime(10) = " + isPrime(10));
    System.out.println("isPrime(9) = " + isPrime(9));
    System.out.println("isPrime(7) = " + isPrime(7));
  }

  //JBook semantics don't support operator String + boolean, that's why we need String here
  String isPrime(int n) {
    switch (n) {
      case 2:
      case 3:
      case 5:
      case 7:
        return "true";
      default:
        return "false";
    }
  }
}
