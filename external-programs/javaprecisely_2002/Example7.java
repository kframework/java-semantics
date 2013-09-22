// Example 7 from page 9 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example7 {
  public static void main(String[] args) {
    System.out.println(ecount(""));
    System.out.println(ecount("hjsdafj yew eqwh ge Ee"));
    System.out.println(ecount("hjsdafj yew fqwh gf Ef"));
  }

  static int ecount(String s) {
    int ecount = 0;
    for (int i=0; i<s.length(); i++)
      if (s.charAt(i) == 'e') 
        ecount++;
    return ecount;
  }
}

