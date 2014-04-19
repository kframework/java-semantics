public class exp_conv_02_primitive_var_init_cast {
  public static void main(String[] args) {
    byte bt = (byte) 100;
    short sh = (short) 1000;
    int i = (int) 1000000;
    long l = (long) 9000000000L;
    char ch = (char) 50000;
    System.out.println("" + bt + " " + sh + " " + i + " " + l + " " + (int)ch);
    System.out.println("Done!");
  }
}
