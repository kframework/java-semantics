class c {
  int x;
  void c() {  // constructor method, so no need to type it
    x=5;
  }
  int g() {
    return x;
  }
}

public class main {
  void main(String[] args) {
    System.out.print((new c()).g());
  }
}
