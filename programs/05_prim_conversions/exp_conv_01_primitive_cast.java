public class exp_conv_01_primitive_cast {
  public static void main(String[] args) {
    System.out.println(""
        + (byte)(byte)100 + " "
        + (byte)(short)1000 + " "
        + (byte)(int)1000000 + " "
        + (byte)(long)9000000000L + " "
        + (byte)(char)50000);
    System.out.println(""
        + (short)(byte)100 + " "
        + (short)(short)1000 + " "
        + (short)(int)1000000 + " "
        + (short)(long)9000000000L + " "
        + (short)(char)50000);
    System.out.println(""
        + (int)(byte)100 + " "
        + (int)(short)1000 + " "
        + (int)(int)1000000 + " "
        + (int)(long)9000000000L + " "
        + (int)(char)50000);
    System.out.println(""
        + (long)(byte)100 + " "
        + (long)(short)1000 + " "
        + (long)(int)1000000 + " "
        + (long)(long)9000000000L + " "
        + (long)(char)50000);
    System.out.println(""
        + (int)(char)(byte)100 + " "
        + (int)(char)(short)1000 + " "
        + (int)(char)(int)1000000 + " "
        + (int)(char)(long)9000000000L + " "
        + (int)(char)(char)50000);
    System.out.println("Done!");
  }
}
