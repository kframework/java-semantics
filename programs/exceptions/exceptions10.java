public class Main {

  int x;

  void main(string[] args) {
    x = 5;
    try {
      throw 3;
      print(x);       // should not print this
    } catch(int y) {
      print(y,"\n");  // should print this
    }
  }
}

// 3
