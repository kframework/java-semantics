/*
All as previous + default case. Default case is not the first one,
  not the last one, so there is a switch group after default and some
  trailing cases too. Default is in the same group with another cases,
  having one case before and one case after.
*/

class main {
	static void howMany(int k) {
    print(k,": ");
		switch (k) {
			case 1:
        print("1 ");
      case 2:
			default:
      case 3:
        print("2-default-3 ");
      case 4:
			case 5:
        print("4-5 ");
			case 6:
      case 7:
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
    howMany(7);
    howMany(8);
    print("Done!","\n");
	}
}

/*
1: 1 2-default-3 4-5
2: 2-default-3 4-5
3: 2-default-3 4-5
4: 4-5
5: 4-5
6:
7:
8: 2-default-3 4-5
Done!
*/
