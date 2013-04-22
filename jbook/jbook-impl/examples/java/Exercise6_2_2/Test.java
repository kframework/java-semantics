class E extends Exception {
  public int contents;

  public E(int i) {
    contents = i;
  }

  public String toString() {
    return "E(" + contents + ")";
  }
}

class Test {
  public static void main(String[] argv) {
    int i = 0;
    while (i<4) {
     try {
       test(i);
     }
     catch (Exception e) {
       System.out.println("test(" + i + ") threw " + e);
     }
     i = i + 1;
    }
  }

  public static int test(int i) throws E {
    try {
      if (i<3) 
        throw new E(10/i);
      else
       return 0;
    }
    finally {
      System.out.println("test(" + i + ") done");
    }
  }
}
