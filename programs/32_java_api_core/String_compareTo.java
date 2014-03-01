// Example 8 from page 9 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class String_compareTo {
  public static void main(String[] args) {
    String[] ss0 = { "", "abde", "abdf", "b" };
    System.out.println(sorted(ss0));
    String[] ss1 = { };
    System.out.println(sorted(ss1));
    String[] ss2 = { "jhkjfgsad " };
    System.out.println(sorted(ss2));
    String[] ss3 = { "Baaaa", "Abbbb" };
    System.out.println(sorted(ss3));
    System.out.println("Done!");
  }

  static boolean sorted(String[] a) {
    for (int i=1; i<a.length; i++)
      if (a[i-1].compareTo(a[i]) > 0)
        return false;
    return true;
  }
}

