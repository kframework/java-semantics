// Testing continue with label inside try/finally inside for. Finally block should execute
// after continue was executed.

public class main {

  void main(string[] args) {
    int i;
    label_1:
    for(i=0; i<10; i++) {
      try {
        if (i % 2 != 0) continue label_1;
        print(i,"-");
      } finally {
        print(i, " ");
      }
    }
    print("\n", "final i = ", i, "\n");
    print("Done!", "\n");
  }
}

// 0-0 1 2-2 3 4-4 5 6-6 7 8-8 9
// final i = 10
// Done!
