// Example 33 from page 25 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)

import java.util.*;

class Example33 {
  public static void main(String[] args) {
    Scanner scanner = new Scanner(System.in);
    String s = scanner.nextLine();
    Iterator seq = suffixes(s);
      while (seq.hasNext())
        System.out.println(seq.next());
  }

  // Create and return an iterator over all non-empty suffixes of s
  static Iterator suffixes(final String s) {
    return
      new Iterator() {
          int startindex=0;
          public boolean hasNext() { return startindex < s.length(); }
          public Object next() { return s.substring(startindex++); }
          public void remove() { throw new UnsupportedOperationException(); }
        };
  }
}

