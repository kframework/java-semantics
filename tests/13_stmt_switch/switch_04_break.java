/*
  As in previous test for switch + break statement.
  All switch features are exposed in this test.
*/

public class switch_04_break {
	static void howMany(int k) {
    System.out.print(k+": ");
		switch (k) {
			case 1:
        System.out.print("1 ");
        break;
      case 2:
			default:
      case 3:
        System.out.print("2-default-3 ");
      case 4:
			case 5:
        System.out.print("4-5 ");
			case 6:
      case 7:
		}
    System.out.println();
	}

	public static void main(String[] args) {
		howMany(1);
		howMany(2);
		howMany(3);
		howMany(4);
		howMany(5);
		howMany(6);
    howMany(7);
    howMany(8);
    System.out.println("Done!");
	}
}

/*
1: 1
2: 2-default-3 4-5
3: 2-default-3 4-5
4: 4-5
5: 4-5
6:
7:
8: 2-default-3 4-5
Done!
*/
