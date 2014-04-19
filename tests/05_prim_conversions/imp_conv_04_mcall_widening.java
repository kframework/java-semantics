/*
Method invocation - widening primitive conv:
  byte to byte, short, int, long
  short to short, int, long
  int int, long
  long to long
  char to int, long, char
*/
public class imp_conv_04_mcall_widening {
  public static void main(String[] args) {
    new Impl();
  }
}

class Impl {
  Impl() {
    byte sb;
    short ss;
    int si;
    long sl;
    char sc;
    sb = (byte)100;
    ss = (short)-1100;
    si = (int)1100200;
    sl = (long)9876543210L;
    sc = (char)'z';

    //byte to others
    System.out.println(""+fb(sb)+" "+fs(sb)+" "+fi(sb)+" "+fl(sb));

    //short to others
    System.out.println(""+fs(ss)+" "+fi(ss)+" "+fl(ss));

    //int to others
    System.out.println(""+fi(si)+" "+fl(si));

    //long to others
    System.out.println(""+fl(sl));

    //char to others
    System.out.println(""+fi(sc)+" "+fl(sc)+" "+fc(sc));

    System.out.println("Done!");
  }

  byte fb(byte param) {
    return param;
  }
  short fs(short param) {
    return param;
  }
  int fi(int param) {
    return param;
  }
  long fl(long param) {
    return param;
  }
  int fc(char param) {
    return (int)param;
  }
}
