// Testing try with multiple catch clauses

class Exception {
  void Exception() {
  }
}

class Exception2 extends Exception {
  void Exception2() {
  }
}

class Exception3 extends Exception2 {
  void Exception3() {
  }
}

public class main {
  void main(String[] args) {
    try {
      throw new Exception2();

      System.out.println("No exception");
    } catch (Exception3 e3) {
      System.out.println("Caught exception3");
    } catch (Exception2 e2) {
      System.out.println("Caught exception2");
    } catch (Exception e) {
      System.out.println("Caught exception");
    }
    System.out.println("Done!");
  }
}

// Caught exception2
// Done!
