/*
Conditional of numeric types.
  Pairs: all 5*5 pairs of integer numeric types.
  Function args: all numeric types
*/

public class op_cond_type_02_numeric {
  public static void main(String[] args) {
    byte b = 0;
    short s = 0;
    int i = 0;
    long l = 0;
    char c = 0;

    System.out.println("byte  byte  : " + f(true ? b : b));
    System.out.println("byte  short : " + f(true ? b : s));
    System.out.println("byte  int   : " + f(true ? b : i));
    System.out.println("byte  long  : " + f(true ? b : l));
    System.out.println("byte  char  : " + f(true ? b : c));
    System.out.println();

    System.out.println("short byte  : " + f(true ? s : b));
    System.out.println("short short : " + f(true ? s : s));
    System.out.println("short int   : " + f(true ? s : i));
    System.out.println("short long  : " + f(true ? s : l));
    System.out.println("short char  : " + f(true ? s : c));
    System.out.println();

    System.out.println("int   byte  : " + f(true ? i : b));
    System.out.println("int   short : " + f(true ? i : s));
    System.out.println("int   int   : " + f(true ? i : i));
    System.out.println("int   long  : " + f(true ? i : l));
    System.out.println("int   char  : " + f(true ? i : c));
    System.out.println();

    System.out.println("long  byte  : " + f(true ? l : b));
    System.out.println("long  short : " + f(true ? l : s));
    System.out.println("long  int   : " + f(true ? l : i));
    System.out.println("long  long  : " + f(true ? l : l));
    System.out.println("long  char  : " + f(true ? l : c));
    System.out.println();

    System.out.println("char  byte  : " + f(true ? c : b));
    System.out.println("char  short : " + f(true ? c : s));
    System.out.println("char  int   : " + f(true ? c : i));
    System.out.println("char  long  : " + f(true ? c : l));
    System.out.println("char  char  : " + f(true ? c : c));
    System.out.println();

    System.out.println("Done!");
  }

  static String f(byte a) {
    return "byte";
  }

  static String f(short a) {
    return "short";
  }

  static String f(int a) {
    return "int";
  }

  static String f(long a) {
    return "long";
  }

  static String f(char a) {
    return "char";
  }
}
