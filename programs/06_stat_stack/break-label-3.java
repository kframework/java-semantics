// Test with one label, one labeled break, all inside while.
// Due to a bug in k definition, there was a strange interaction
// between labeled break and loops.
public class main {
  void main(string[] args) {
    int i=0, a=0;
    while(i<3) {
      label_1: {
        print("Before break ", i, ", ");
        break label_1;
        print("unreachable");
      }
      print("after break ", i, "\n");
      i++;
    }
    print("Done!", "\n");
  }
}
// Before break 0, after break 0
// Before break 1, after break 1
// Before break 2, after break 2
// Done!
