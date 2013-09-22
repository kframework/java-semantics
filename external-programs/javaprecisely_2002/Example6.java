// Example 6 from page 9 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example6 {
  public static void main(String[] args) {
    String[] myArgs = {"a", "bb", "ccc"};
    String res = "";
    for (int i=0; i<myArgs.length; i++)
      res += myArgs[i];
    System.out.println(res);
  }
}

