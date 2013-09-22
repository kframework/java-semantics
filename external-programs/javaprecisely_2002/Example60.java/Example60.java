// Example 60 from page 45 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example60 {
  public static void main(String[] args) {
    System.out.println("Counting sum of eyes until 5 or 6 comes up (1000 dice).");
    int[] wait = new int[100];

    //java semantics: originaly here were 10000 iterations ~40 min of execution.
    for (int i=0; i<250; i++)
      wait[waitsum()]++;
    System.out.println("sum: frequency");
    for (int w=5; w<20; w++)
      System.out.println(w + ": " + wait[w]);
  }

  // Roll a die and compute sum until five or six comes up
  static int waitsum() {
    int sum = 0, eyes;
    do {
      eyes = (int)(1 + 6 * Math.random());
      sum += eyes;
    } while (eyes < 5);
    return sum;
  }
}

