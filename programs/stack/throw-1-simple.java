//Testing simple throw.
//Also catch argument shadowing a local variable with the same name.

class Exception {
  Exception(){}
}

public class main {
  void main(string[] args) {
    int e = 100;
    try {
      int x = 5;
      if (x >= 0)
        throw new Exception();
      print("unreachable");
    } catch(Exception e) {
      print(e, " ","\n");   // should print Exception
    }
    print(e, " ","\n");     // should print 100
    print("Done!", "\n");
  }
}
// Exception
// 100
// Done!
