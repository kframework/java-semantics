import java.util.*;

public class max3 {

	public static void main(String[] args) {
    System.out.print("Insert 3 numbers: ");
    Scanner scanner = new Scanner(System.in);
    int a = scanner.nextInt();
    int b = scanner.nextInt();
    int c = scanner.nextInt();
    int max;
    if (a > b) {
      if (a > c) {
        max = a;
      } else {
        max = c;
      }
    } else {
      if (b > c) {
        max = b;
      } else {
        max = c;
      }
    }
    System.out.println("max = " + max);
    System.out.println("Done!");
	}
}

// (for input 6 12 8)

// Insert 3 numbers: max = 12
// Done!
