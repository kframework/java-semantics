// Testing mutually recursive uses of this.method

class OddEven {
  int n;

  OddEven(int x) {
    n = x;
  }

  int even() {
    if (n == 0)
      return 1;
    else {
      n = n - 1;
      return this.odd();
    }
  }

  int odd() {
    if (n == 0)
      return 0;
    else {
      n = n - 1;
      return this.even();
    }
  }
}

public class odd_even {
  public static void main(String[] args) {
    System.out.println((new OddEven(17)).odd());
  }
}

// 1
