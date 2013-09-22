// Example 10 from page 11 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example10 {
  public static void main(String[] args) {
    // Roll a die, count frequencies
    int[] freq = new int[6];                    // all initialized to 0

    //java semantics: running until 1000 takes 3 min, too much.
    for (int i=0; i<500; i++) {
      int die = (int)(1 + 6 * Math.random());
      freq[die-1] += 1;
    }
    for (int c=1; c<=6; c++)
      System.out.println(c + " came up " + freq[c-1] + " times");

    // Create an array of the strings "A0", "A1", ..., "A19"
    String[] number = new String[20];           // all initialized to null
    for (int i=0; i<number.length; i++)
      number[i] = "A" + i;
    for (int i=0; i<number.length; i++)
      System.out.println(number[i]);
  }
}
