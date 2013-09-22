// Example 33 from page 25 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)

import java.util.Iterator;

class Example33 {
  public static void main(String[] args) {
    if (args.length != 1) 
      System.out.println("Usage: java Example33 <string>\n");
    else {
      Iterator seq = suffixes(args[0]);
      while (seq.hasNext())
        System.out.println(seq.next());
    }
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

