// Testing simple break inside labeled while loop.

public class main {

  void main(string[] args) {
    int i=0;
    label_1:
    while (i<10) {
      if (i >= 5) break;
      print(i," ");
      i++;
    }
    print("\n", "final i = ", i, "\n");
    print("Done!","\n");
  }
}

// 0 1 2 3 4
// final i = 5
// Done!
