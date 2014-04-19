// Accessing hidden fields through super in a three-level hierarchy.

class C1 {
  int x, y;

  C1() {
    x=1;
    y=2;
  }
}

class C2 extends C1 {
  int y, z;

  C2() {
    y=20;
    z=super.y;
  }
}

class C3 extends C2 {
  int x, y, z, u, w;

  C3() {
    x=100;
    y=200;
    z=super.x;
    u=super.y;
    w=super.z;
  }
}

public class fields_133_hiding_super_2 {
  public static void main(String[] args) {
    C3 o = new C3();
    System.out.println(o.x + " "+ o.y+ " "+ o.z+ " "+ o.u+ " "+ o.w);
  }
}

// 100 200 1 20 2
