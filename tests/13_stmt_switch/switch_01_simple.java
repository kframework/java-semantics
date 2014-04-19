//Testing simple switch statement.
//Testing both context rules.
//Multiple swtch groups. One case for group.

public class switch_01_simple {
	static void howMany(int k) {
    System.out.print(k+": ");
		switch (k) {
			case 1 + 0: System.out.print("1 ");
			case 2: System.out.print("2 ");
			case 3: System.out.print("3 ");
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
1: 1 2 3
2: 2 3
3: 3
4:
Done!
*/
