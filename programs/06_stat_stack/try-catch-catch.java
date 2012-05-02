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

class main {
  void main(string[] args) {
    try {
      throw new Exception2();

      print("No exception","\n");
    } catch (Exception3 e3) {
      print("Caught exception3","\n");
    } catch (Exception2 e2) {
      print("Caught exception2","\n");
    } catch (Exception e) {
      print("Caught exception","\n");
    }
    print("Done!", "\n");
  }
}

// Caught exception2
// Done!
