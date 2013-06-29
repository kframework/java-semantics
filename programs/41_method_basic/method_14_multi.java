/*
Multiple methods, multiple argument types/numbers:
  - method negation(one arg),
  - method max(two args),
  - method arrayLen(one arg)
*/

public class method_14_multi {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    System.out.println(negation(12));
    System.out.println(max(10, 14));
    System.out.println(arrayLen(new int[0]));
  }

  int negation(int a) {
    return -a;
  }

  int max(int a, int b) {
    return a > b ? a : b;
  }

  int arrayLen(int[] v) {
    return v.length;
  }
}
