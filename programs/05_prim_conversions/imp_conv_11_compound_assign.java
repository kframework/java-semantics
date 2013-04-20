/*
Compound assignment with overflow:
  short op= int, all operators.
  Operators are: += -= *= /= &= |= ^= %= <<= >>= >>>=
*/
public class imp_conv_11_compound_assign {
  public static void main(String[] args) {
    short s = 32767;
    System.out.println((s+=32767));
    s = 32767;
    System.out.println(s -= 1000000);
    s = 32767;
    System.out.println(s *= 200);
    s = 32767;
    System.out.println(s /= 4);
    s = -32768;
    System.out.println(s &= 32768);
    s = 32767;
    System.out.println(s |= 100000);
    s = 32767;
    System.out.println(s ^= 65537);
    s = 32767;
    System.out.println(s %= 1);
    s = 32767;
    System.out.println(s <<= 2);
    s = 32767;
    System.out.println(s >>= 2);
    s = 32767;
    System.out.println(s >>>= 2);

    System.out.println("Done!");
  }
}

