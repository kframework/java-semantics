/* Testing simple break inside labeled do loop.
Break halts the loop on first iteration.
If do statement is desugared to its body followed by a while statement,
then break will be executed outside the loop.
Such a semantics for do was correct in absence of break and continue,
but now do statement needs a special threatment.
*/

public class main {

  void main(string[] args) {
    label_1:
    do {
      break;
      print("unreachable");
    } while (true);
    print("Done!", "\n");
  }
}

// Done!
