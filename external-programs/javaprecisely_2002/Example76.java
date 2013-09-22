// Example 76 from page 59 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Printer extends Thread {
  static Object mutex = new Object();
  public void run() {
    for (int i=0; i<10; i++) {
      synchronized (mutex) {
        System.out.print("-");
        //Util.pause(100,300);
        System.out.print("/");
      }
      //Util.pause(200);
} } }

class Example76 {
  public static void main(String[] args)
  { new Printer().start(); new Printer().start(); }
}

