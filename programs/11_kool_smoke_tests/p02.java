class c {
  int x;

  c() {  // constructor method, so no need to type it
    x=5;
  }

  int g() {
    return x;
  }
}

class main {
  main(String[] args) {
    System.out.println((new c()).g());
    System.out.println("Done!");
  }
}

public class p02 {
  public static void main(String[] args) {
    new main(args);
  }
}
