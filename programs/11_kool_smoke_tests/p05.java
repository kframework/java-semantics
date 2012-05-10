class c1 {
  int x, y;
  //       method c1() { }  // not necessary, because we create no instance of c1
  void setx1(int v) { x=v; }
  void sety1(int v) { y=v; }
  int getx1() { return x; }
  int gety1() { return y; }
}

class c2 extends c1 {
  int y;
  void c2() { }   // such empty constructs are necessary when creating instances
  // of the class; they are not necessary otherwise (see c1 above)
  void sety2(int v) { y=v; }
  int getx2() { return x; }
  int gety2() { return y; }
}

public class main {
  void main(String[] args) {
    c2 o2 = new c2();
    o2.setx1(11);
    o2.sety1(12);
    o2.sety2(99);
    System.out.print(""+o2.getx1()+ o2.gety1()+ o2.getx2()+ o2.gety2());
  }
}

