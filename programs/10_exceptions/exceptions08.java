class main {

  void main(String[] args) {
    int e;
    try {
      try {
        try {
          try {
            int x = 1; System.out.print(x+" "); throw ++x;
          } catch(int e) {
            System.out.print(e+" ");
            throw ++e;
          }
        } catch(int e) {
          System.out.print(e+" ");
          throw ++e;
        }
      } catch(int e) {
        System.out.print(e+" ");
        throw ++e;
      }
    } catch(int e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}

// 1 2 3 4 5
// Done!
