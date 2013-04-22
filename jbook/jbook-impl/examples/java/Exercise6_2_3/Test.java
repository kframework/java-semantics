public class Test {
  public static void main(String[] argv) {
    int i = 0;
    while (i<4) {
     try { m(i); }
     catch (Exception e) {
       System.out.println(e + " handled in main");
     }
     i = i + 1;
    }
  }

  public static void m(int i) throws Exception {
    try {
     System.out.println("m(" + i + ") called");
     if (i%2==0) throw new Exception("m("+i+")");
    }
    catch (Exception e) {
      System.out.println(e + " handled in m(" + i + ")");
      throw e;
    }
    finally {
      System.out.println("m("+i+") done");
    }
  }
}
