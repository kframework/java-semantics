// Testing continue with label inside try/catch inside for. Try./catch should not affect
// continue behavior, even if both interact with the same stack.

public class main {

  void main(String[] args) {
    int i;
    label_1:
    for(i=0; i<10; i++) {
      try {
        if (i % 2 != 0) continue label_1;
      } catch(int ex) {
        System.out.print("never reached");
      }
      System.out.print(i+" ");
    }
    System.out.println("\n"+ "final i = "+ i);
    System.out.println("Done!");
  }
}

// 0 2 4 6 8
// final i = 10
// Done!
