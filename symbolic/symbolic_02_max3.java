/*
kompile -v java --symbolic-rules "symbolic-rule" --backend symbolic

time timeout 300 krun --debug-info --color extended --directory="." --main-module=JAVA \
  -cMainClass="ListItem(\"symbolic_02_max3\")" -cModelCheck="false" --output=pretty --parser="kj-parse-aggreg.sh" \
  ../symbolic/symbolic_02_max3.java \
  -cIN="ListItem(3) ListItem(#symInt(x)) ListItem(8)" -cPC=true --search

Expected output: 3 solutions
*/
import java.util.*;

public class symbolic_02_max3 {

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
