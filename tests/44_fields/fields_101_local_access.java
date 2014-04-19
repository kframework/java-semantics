/*
Fields with unqualified access. Read and write a field from inside the class.
*/

class c {
  int x;

  c() {  // constructor method, so no need to type it
    x=5;
  }

  int g() {
    return x;
  }
}

public class fields_101_local_access {
  public static void main(String[] args) {
    System.out.println((new c()).g());
    System.out.println("Done!");
  }
}
