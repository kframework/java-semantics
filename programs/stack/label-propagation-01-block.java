// break label -> simple doWhile -> matched labeled block.

public class main {

  void main(string[] args) {
    label_1: {
      do {
        print("Inside doWhile","\n");
        break label_1;
        print("unreachable 1");
      } while(true);
      print("unreachable 2");
    }
    print("Done!", "\n");
  }
}

// Inside doWhile
// Done!
