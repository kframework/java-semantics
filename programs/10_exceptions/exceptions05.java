public class main {

  int x;

  int f(int y) {
    int t = 1;
    try{
      print(t," ");
      throw 5;
      print(8);      // not reachable
    } catch(int p) {
      print(p+10," ");
    }
    for (int i = 1; i<=y; ++i)
      t = t*i;
    return t;
  }

  void main(string[] args) {
    x = 5;
    print(f(x),"\n");
    print("Done!","\n");
  }
}

// 1 15 120
// Done!
