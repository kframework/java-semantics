/*
Compound assignment with overflow, selections:
  byte += int
  short += int
  int += int
  long += int
  char += int
*/
public class imp_conv_12_compound_assign_sel {
  public static void main(String[] args) {
    byte b = 127;
    System.out.println((b+=100));
    short s = 30000;
    System.out.println((s+=10000));
    int i = 2000000000;
    System.out.println((i+=2000000000));
    long l = 2000000000;
    System.out.println((l+=2000000000));
    char c = 50000;
    System.out.println((int)(c+=50000));

    System.out.println("Done!");
  }
}

