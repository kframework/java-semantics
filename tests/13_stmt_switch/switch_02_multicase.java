//Multiple switch groups. Multiple cases for group. Multiple trailing cases.

public class switch_02_multicase {
	static void howMany(int k) {
    System.out.print(k+": ");
		switch (k) {
			case 1+0:
        System.out.print("1 ");
      case 2+0:
			case 3+0:
        System.out.print("2-3 ");
			case 4+0:
      case 5+0:
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
    System.out.println("Done!");
	}
}

/*
1: 1 2-3
2: 2-3
3: 2-3
4:
5:
6:
Done!
*/
