// test of doWhile

class main {

	main(String[] args) {
    int i=0, j=0;
		do i++; while (false);
    do j++; while (j < 3);

    System.out.println(i+" "+j);
    System.out.println("Done!");
	}
}

public class doWhile_1 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 1 3
// Done!
