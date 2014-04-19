/*
Binary promotion: ?: operator:
case 1:
  byte+byte->byte
  short_short->short
  int_int->int
  long_long->long
  char_char->char

case 2:
  byte_short->short
  byte_int->int
  byte_long->long
  char_short->int
  short_byte->short

case 3:
  byte_byteconst->byte
  short_shortconst->short
  int_intconst->int
  long_longconst->long
  char_charconst->char
  byteconst_byte->byte
*/
public class imp_conv_09_bin_prom_cond_op {
  public static void main(String[] args) {
    byte b = 100;
    short s = 1000;
    int i = 1000000;
    long l = 9876543210L;

    //case 1
    char c = 'v';
    byte br = true ? b : b;
    short sr = true ? s : s;
    int ir = true ? i : i;
    long lr = true ? l : l;
    char cr = true ? c : c;
    System.out.println(""+br+" "+sr+" "+ir+" "+lr+" "+cr);

    //case 2
    sr = false ? b : s;
    ir = false ? b : i;
    lr = false ? b : l;
    int ir2 = false ? c : s;
    short sr2 = false ? s : b;
    System.out.println(""+sr+" "+ir+" "+lr+" "+ir2+" "+sr2);

    //case 3
    br = true ? b : 101;
    sr = true ? s : 101;
    ir = true ? i : 101;
    lr = true ? l : 101;
    cr = true ? c : 101;
    byte br2 = true ? 101 : b;
    System.out.println(""+br+" "+sr+" "+ir+" "+lr+" "+cr+" "+br2);

    System.out.println("Done!");
  }
}

