/*
All like in test 4, but break is inside default clause.
Testing the default clause + break combination.
*/

public class switch_08_default_break {
	static void howMany(int k) {
    System.out.print(k+": ");
		switch (k) {
			case 1:
        System.out.print("1 ");
      case 2:
			default:
      case 3:
        System.out.print("2-default-3 ");
        break;
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
