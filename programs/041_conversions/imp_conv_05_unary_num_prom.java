/*
Unary numeric promotion:
  short in +/-/~
  short_short in >>, <<, >>>
  long_short in >>, <<, >>>
  short_long in >>, <<, >>>
  Result fitting in promoted type only, where possible.
*/
public class imp_conv_05_unary_num_prom {
  public static void main(String[] args) {
    System.out.println("" + (+(short)1000) + " " +(-(short)(-32768))
      + " " +((short)(-32768)));
    System.out.println(""
      + ((short)10000 >> (short)2) + " "
      + ((short)10000 << (short)2) + " "
      + ((short)-10000 >>> (short)2) );
    System.out.println(""
      + (10000L >> (short)2) + " "
      + (10000L << (short)24) + " "
      + (-10000L >>> (short)2) );
      System.out.println(""
      + ((short)10000 >> 2L) + " "
      + ((short)10001 << 24L) + " "
      + ((short)-10000 >>> 2L) );
      System.out.println("Done!");
  }
}

