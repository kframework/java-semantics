//return in do-while

public class return_07_do_while {

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
    int i = 2;
    do {
      if (n % i == 0) {
        return "false";
      }
      i++;
    } while(i < n);
    return "true";
  }
}
