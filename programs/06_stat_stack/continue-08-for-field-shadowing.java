// In this test initialisation clause of for declares a variable
// with the same name as the field. After for completes,
// we should be able to access the field again.
// This test also ensures that continue don't disrupt <env> cell restoration
// after for terminates.

public class main {
  int i=-1;

	void main(String[] args) {
    for(int i=0; i<5; i++) {
      System.out.print(i+" ");
      if (i == 4) continue;
    }
    System.out.println("\n"+ "After for i = "+ i);
    System.out.println("Done!");
  }
}

// 0 1 2 3 4
// After for i = -1
// Done!
