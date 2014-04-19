/*
Interaction with loops. One loop inside a switch group, one loop enclosing
  the switch. 3 breaks:
    - break in the inner loop
    - break in switch
    - break in outer loop after switch
*/

public class switch_06_continue {
	public static void main(String[] args) {
    for(int i=0; i<4; i++) {
      System.out.print(i+": ");
      switch (i) {
        case 1:
          System.out.print("1 ");
        case 2:
          System.out.println("2 ");
          continue;
        case 3:
          System.out.print("3 ");
      }
      System.out.print("+");
      System.out.println();
    }
    System.out.println("Done!");
	}
}

/*
0: +
1: 1 2
2: 2
3: 3 +
Done!
*/
