public class Main {

  void main(string[] args) {
    try {
      15;
    } catch(int e) {
      print(e);   // should not print this
    }
    print(42,"\n");
  }
}

// 42
