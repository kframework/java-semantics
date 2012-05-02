/*
Interaction with loops. One loop inside a switch group, one loop enclosing
  the switch. 3 breaks:
    - break in the inner loop
    - break in switch
    - break in outer loop after switch
*/

class main {
	public static void main(string[] args) {
    for(int i=0; i<4; i++) {
      print(i,": ");
      switch (i) {
        case 1:
          print("1 ");
        case 2:
          print("2 ","\n");
          continue;
        case 3:
          print("3 ");
      }
      print("+");
      print("\n");
    }
    print("Done!","\n");
	}
}

/*
0: +
1: 1 2
2: 2
3: 3 +
Done!
*/
