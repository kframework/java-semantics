// Testing break inside try/finally inside for. Finally block should execute
// after break was executed

public class main {

  void main(string[] args) {
    int i;
    for(i=0; i<10; i++) {
      try {
        if (i >= 5) break;
        print(i);
      } finally {
        print("-", i, " ");
      }
    }
    print("\n", "final i = ", i, "\n");
    print("Done!", "\n");
  }
}

// 0-0 1-1 2-2 3-3 4-4 -5
// final i = 5
// Done!
