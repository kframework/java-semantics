// Test with two labels, one labeled break.
public class main {
  void main(string[] args) {
    label_1: {
      label_2: {
        print("Before break","\n");
        break label_1;
        print("unreachable");
      }
      print("unreachable 2");
    }
    print("Done!","\n");
  }
}
// Before break
// Done!
