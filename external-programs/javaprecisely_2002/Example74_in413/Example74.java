// Example 74 from page 55 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


// To exercise all paths through the try-catch-finally statement in
// method m, run this program with each of these arguments:
// 101 102 103 201 202 203 301 302 303 411 412 413 421 422 423 431 432 433
// like this:
//    java Example74 101
//    java Example74 102
//    etc

import java.util.Scanner;

class Example74 {
  public static void main(String[] args) throws Exception {
    Scanner scanner = new Scanner(System.in);
    int a = scanner.nextInt();
    System.out.println(m(a));
  }

  static String m(int a) throws Exception {
    try {
      System.out.print("try ... ");
      if (a/100 == 2) return "returned from try";
      if (a/100 == 3) throw new Exception("thrown by try");
      if (a/100 == 4) throw new RuntimeException("thrown by try");
    } catch (RuntimeException x) {
      System.out.print("catch ... ");
      if (a/10%10 == 2) return "returned from catch";
      if (a/10%10 == 3) throw new Exception("thrown by catch");
    } finally {
      System.out.println("finally");
      if (a%10 == 2) return "returned from finally";
      if (a%10 == 3) throw new Exception("thrown by finally");
    }
    return "terminated normally with " + a;
  }
}

