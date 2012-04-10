//Multiple switch groups. Multiple cases for group. Multiple trailing cases.

class main {
	static void howMany(int k) {
    print(k,": ");
		switch (k) {
			case 1 + 0: print("1 ");
      case 2:
			case 3: print("2-3 ");
			case 4:
      case 5:
		}
    print("\n");
	}

	public static void main(string[] args) {
		howMany(1);
		howMany(2);
		howMany(3);
		howMany(4);
		howMany(5);
		howMany(6);
    print("Done!","\n");
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
