/*
Interaction with loops. One loop inside a switch group, one loop enclosing
  the switch. 3 breaks:
    - break in the inner loop
    - break in switch
    - break in outer loop after switch
*/

class main {
	static void howMany(int k) {
    print(k,": ");
    while(true) {
      switch (k) {
        case 1:
          print("1, ");
          while(true) {
            print("inner while, ");
            break;
            print("unreachable");
          }
        case 2:
          print("2, ");
          break;
          print("unreachable");
        case 3:
          print("3, ");
      }
      print("after switch, ");
      break;
      print("unreachable");
    }
    print("after outer while.");
    print("\n");
	}

	public static void main(string[] args) {
		howMany(1);
    print("Done!","\n");
	}
}

/*
1: 1, inner while, 2, after switch, after outer while.
Done!
*/
