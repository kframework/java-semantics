/*
12. Two overloaded methods:
   f(int), f(int, int), g(int), g(int,int). Call all of them.
*/

public class overload_12_two_methods {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    f(2);
    f(3,9);
    g(4);
    g(5,25);
  }

  void f(int a) {
    System.out.println("f:" +a);
  }

  void f(int a, int b) {
    System.out.println("f:"+a+" "+b);
  }

  void g(int a) {
    System.out.println("g:" +a);
  }

  void g(int a, int b) {
    System.out.println("g:"+a+" "+b);
  }
}
