// Testing try with multiple catch clauses

class Exception2 extends RuntimeException {
  Exception2() {
    super();
  }
}

class Exception3 extends Exception2 {
  Exception3() {
  }
}

public class throw_06_try_CCCF {
  public static void main(String[] args) {
    try {
      if (true) throw new Exception2();

      System.out.println("unreachable");
    } catch (Exception3 e3) {
      System.out.println("Caught Exception3");
    } catch (Exception2 e2) {
      System.out.println("Caught Exception2");
    } catch (RuntimeException e) {
      System.out.println("Caught RuntimeException");
    } finally {
      System.out.println("finally");
    }
    System.out.println("Done!");
  }
}

// Caught Exception2
// finally
// Done!
