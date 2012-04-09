// Testing break with label inside try/finally inside for (the labeled statement).
// Finally block should execute after break was executed

public class main {

  void main(string[] args) {
    int i;
    label_1:
    for(i=0; i<10; i++) {
      try {
        if (i >= 5) break label_1;
        print(i);
      } finally {
        print("-", i, " ");
      }
    }
    print("\n", "final i = ", i, "\n");
  }
}

// 0-0 1-1 2-2 3-3 4-4 -5
// final i = 5
