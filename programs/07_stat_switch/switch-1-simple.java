//Testing simple switch statement.
//Testing both context rules.
//Multiple swtch groups. One case for group.

class main {
	static void howMany(int k) {
    print(k,": ");
		switch (k) {
			case 1 + 0: print("1 ");
			case 2: print("2 ");
			case 3: print("3 ");
		}
    print("\n");
	}

	public static void main(string[] args) {
		howMany(1);
		howMany(2);
		howMany(3);
		howMany(4);
    print("Done!","\n");
	}
}

/*
1: 1 2 3
2: 2 3
3: 3
4:
Done!
*/
