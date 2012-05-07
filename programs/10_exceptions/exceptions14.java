class main {

  void main(String[] args) {
    try {
      15;
    } catch(int e) {
      System.out.print(e);   // should not print this
    }
    System.out.println(42);
    System.out.println("Done!");
  }
}

// 42
// Done!
