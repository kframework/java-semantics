// Testing continue with label inside do loop, test 2.
// Now continue occurs on first iteration.
// If do statement is desugared to its body followed by a while statement,
// then first continue will be executed outside the loop.
// Such a semantics for do is correct in absence of continue statement,
// but leads to problems when we add semantics for continue.

public class continue_label_03_do_2 {

  public static void main(String[] args) {
    int i=0;
    label_1:
    do {
      int j = i;
      i++;
      if (j % 2 == 0) continue label_1;
      System.out.print(j+" ");
    } while (i<10);
    System.out.println();
    System.out.println("Done!");
  }
}

// 1 3 5 7 9
// Done!
