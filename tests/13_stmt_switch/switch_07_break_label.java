/*
Interaction with break with label.
  Switch in labeled block. Break with label in switch.
*/

public class switch_07_break_label {
	static void howMany(int k) {
    System.out.print(k+": ");
    label_1: {
      switch (k) {
        case 1:
          System.out.print("1 ");
          break;
        case 2:
          System.out.print("2 ");
          break label_1;
        case 3: System.out.print("3 ");
      }
      System.out.print(", after switch.");
    }
    System.out.println();
	}

	public static void main(String[] args) {
		howMany(1);
		howMany(2);
		howMany(3);
		howMany(4);
    System.out.println("Done!");
	}
}

/*
1: 1 , after switch.
2: 2
3: 3 , after switch.
4: , after switch.
Done!
*/
