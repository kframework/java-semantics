public class Main {

  void main(string[] args) {
    try {
      throw 4;
    } catch (int e) {
      print(e," ");
    }
    print(42,"\n");
  }
}

// 4 42
