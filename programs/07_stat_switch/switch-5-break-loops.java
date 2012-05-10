/*
Interaction with loops. One loop inside a switch group, one loop enclosing
  the switch. 3 breaks:
    - break in the inner loop
    - break in switch
    - break in outer loop after switch
*/

public class main {
	static void howMany(int k) {
    System.out.print(k+": ");
    while(true) {
      switch (k) {
        case 1:
          System.out.print("1, ");
          while(true) {
            System.out.print("inner while, ");
            break;
            System.out.print("unreachable");
          }
        case 2:
          System.out.print("2, ");
          break;
          System.out.print("unreachable");
        case 3:
          System.out.print("3, ");
      }
      System.out.print("after switch, ");
      break;
      System.out.print("unreachable");
    }
    System.out.print("after outer while.");
    System.out.print("\n");
	}

	static void main(String[] args) {
		howMany(1);
    System.out.println("Done!");
	}
}

/*
1: 1, inner while, 2, after switch, after outer while.
Done!
*/
