// Testing break inside do loop, which halts the loop on first iteration.
// If do statement is desugared to its body followed by a while statement,
// then break will be executed outside the loop.
// Such a semantics for do was correct in absence of break and continue,
// but now do statement needs a special threatment.

public class break_02_do {

  public static void main(String[] args) {
    do {
      if (true) break;
      System.out.print("unreachable");
    } while (true);
    System.out.println("Done!");
  }
}

// Done!
