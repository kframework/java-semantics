/*
Cast primitive
long a = 10;
(byte)a : int(a)
*/

public class exp_type_12_cast_prim {
  public static void main(String[] args) {
    long a = 10;

    System.out.println("f(true  ? (byte)getL(1) : (int)getL(4)): " + f(true  ? (byte)getL(1) : (int)getL(4)));
    System.out.println("f(false ? (byte)getL(1) : (int)getL(4)): " + f(false ? (byte)getL(1) : (int)getL(4)));

    System.out.println("Done!");
  }

  static String f(byte b) {
    return "f(byte): " + b;
  }

  static String f(int a) {
    return "f(int): " + a;
  }

  static long getL(long a) {
    System.out.println("getL(" + a + ")");
    return a;
  }
}
