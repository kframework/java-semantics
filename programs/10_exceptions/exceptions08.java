public class main {

  void main(string[] args) {
    int e;
    try {
      try {
        try {
          try {
            int x = 1; print(x," "); throw ++x;
          } catch(int e) {
            print(e," ");
            throw ++e;
          }
        } catch(int e) {
          print(e," ");
          throw ++e;
        }
      } catch(int e) {
        print(e," ");
        throw ++e;
      }
    } catch(int e) {
      print(e,"\n");
    }
    print("Done!","\n");
  }
}

// 1 2 3 4 5
// Done!
