// In this test initialisation clause of for declares a variable
// with the same name as the field. After for completes,
// we should be able to access the field again.

class main {
  int i=-1;

	main(String[] args) {
    for(int i=0; i<5; i++) {
      System.out.print(i + " ");
    }
    System.out.println();
    System.out.println("After for i = "+ i);
    System.out.println("Done!");
  }
}

public class for_field_shadowing {
  public static void main(String[] args) {
    new main(args);
  }
}

// 0 1 2 3 4
// After for i = -1
// Done!
