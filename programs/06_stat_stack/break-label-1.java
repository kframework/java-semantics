// Simple test with labeled break

public class main {
  void main(string[] args) {
    label_1: {
      print("Before break","\n");
      break label_1;
      print("unreachable");
    }
    print("Done!","\n");
  }
}
// Before break
// Done!
