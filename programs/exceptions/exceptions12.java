public class Main {

  int i, j;

  void main(string[] args) {
    i = 0;
    while (++i <= 3) {
      print(i," ");
    }
    try {
      i = 10;
      print(i," ");
    } catch(int j) {
      i = 20;
      print(i);  // should not print this
    }
    i = 15;
    print(i,"\n");
  }
}

// 1 2 3 10 15
