class Exercise6_2_1 {
  public static void main(String[] argv) {
    int i = 0;
  l1 : while (i<5) {
       try {
         if (i==2) break l1;
       }
       finally {
         i = i + 1;
       }
     }
     System.out.println(i);
  }
}

