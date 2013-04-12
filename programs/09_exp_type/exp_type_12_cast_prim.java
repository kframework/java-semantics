/*
Cast primitive
long a = 10;
(byte)a : int(a)
*/

public class exp_type_12_cast_prim {
  public static void main(String[] args) {
    long a = 10;

    System.out.println("f(true  ? (byte)a : (int)a): " + f(true  ? (byte)a : (int)a));
    System.out.println("f(false ? (byte)a : (int)a): " + f(false ? (byte)a : (int)a));

    System.out.println("Done!");
  }

  static String f(byte b) {
    return "f(byte): " + b;
  }

  static String f(int a) {
    return "f(int): " + a;
  }
}
