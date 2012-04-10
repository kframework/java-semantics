/*
All as previous + default case. Default case is not the last one, so there is
  a switch group after default and some trailing cases too. Default is in the same group
  with another case, second after that case.
*/

class main {
	static void howMany(int k) {
    print(k,": ");
		switch (k) {
			case 1 + 0: print("1 ");
      case 2:
			default: print("2-default ");
      case 3:
			case 4: print("3-4 ");
			case 5:
      case 6:
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
    print("Done!","\n");
	}
}
//todo fix results
/*
1: 1 2-3
2: 2-3
3: 2-3
4:
5:
6:
Done!
*/
