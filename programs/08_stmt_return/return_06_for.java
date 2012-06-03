public class return_06_for {

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

  boolean isPrime(int n) {
    for(int i=2; i<n;i++) {
      if (n % i == 0) {
        return false;
      }
    }
    return true;
  }
}
