class a {  // classes are not enforced to have constructors
  // provided that one never creates instances for them
  // indeed, below we only create an instance for a subclass of a (for main)
  int m1(int x) {
    return ++x;
  }
}

class b extends a {
  int x;
  void b() {
    x=3;
  }
}

class main extends b {
  int m1(int y) {
    return  y*y;
  }
  main(String[] args) {
    System.out.println(m1(4));
    System.out.println("Done!");
  }
}

public class p03 {
  public static void main(String[] args) {
    new main(args);
  }
}
