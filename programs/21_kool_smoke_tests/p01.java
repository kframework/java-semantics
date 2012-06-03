class main {       // "new main();" statement automatically generated for any program
  int x;
  main(String[] args) {  // constructor methods have the same name as the class
    // they are called when objects are created for the class
    // they need not be typed; their returned value is discarded anyway
    x=1;
    System.out.println(x+1);
    System.out.println("Done!");
  }
}

public class p01 {
  public static void main(String[] args) {
    new main(args);
  }
}

