public class main {

  void main(string[] args) {
    try {
      throw 4;
    } catch (int e) {
      print(e," ");
    }
    print(42,"\n");
    print("Done!","\n");
  }
}

// 4 42
// Done!
