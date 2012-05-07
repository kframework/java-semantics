// Testing continue with label inside simple for loop

class main {

  void main(String[] args) {
    label_1:
    for(int i=0; i<10; i++) {
      if (i % 2 != 0) continue label_1;
      System.out.print(i+" ");
    }
    System.out.println("\n"+ "Done!");
  }
}

// 0 2 4 6 8
// Done!
