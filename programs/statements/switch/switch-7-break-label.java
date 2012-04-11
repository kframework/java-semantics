/*
Interaction with break with label.
  Switch in labeled block. Break with label in switch.
*/

class main {
	static void howMany(int k) {
    print(k,": ");
    label_1: {
      switch (k) {
        case 1:
          print("1 ");
          break;
        case 2:
          print("2 ");
          break label_1;
        case 3: print("3 ");
      }
      print(", after switch.");
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
1: 1 , after switch.
2: 2
3: 3 , after switch.
4: , after switch.
Done!
*/
