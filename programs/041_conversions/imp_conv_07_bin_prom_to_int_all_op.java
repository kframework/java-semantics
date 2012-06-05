/*
Binary promotion: all operators short and short.
  Specifically the following operators: * / % + - < <= > >= == != & ^ |
  Where possible,the result should not fit in short range.
*/
public class imp_conv_07_bin_prom_to_int_all_op {
  public static void main(String[] args) {
    System.out.println(((short)1000)*(short)1000);
    System.out.println(((short)1000)/(short)1);
    System.out.println(((short)1000)%(short)1000);
    System.out.println(((short)30000)+(short)30000);
    System.out.println(((short)-30000)-(short)-30000);
    System.out.println(((short)1000)<(short)1000);
    System.out.println(((short)1000)<=(short)1000);
    System.out.println(((short)1000)>(short)1000);
    System.out.println(((short)1000)>=(short)1000);
    System.out.println(((short)1000)==(short)1000);
    System.out.println(((short)1000)!=(short)1000);
    System.out.println(((short)-32768)&(short)-16384);
    System.out.println(((short)-32768)^(short)-16384);
    System.out.println(((short)1000)|(short)1000);
    System.out.println("Done!");
  }
}

