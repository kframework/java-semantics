// Testing try with multiple catch clauses

class Exception2 extends RuntimeException {
  void Exception2() {
  }
}

class Exception3 extends Exception2 {
  void Exception3() {
  }
}

public class try_catch_catch {
  public static void main(String[] args) {
    try {
      if (true) throw new Exception2();

      System.out.println("No exception");
    } catch (Exception3 e3) {
      System.out.println("Caught Exception3");
    } catch (Exception2 e2) {
      System.out.println("Caught Exception2");
    } catch (RuntimeException e) {
      System.out.println("Caught RuntimeException");
    }
    System.out.println("Done!");
  }
}

// Caught Exception2
// Done!
