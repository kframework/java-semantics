class Figure16_1 {
   static int m(int i) {
     int j;
     try {
       if (i==0) return i*i;
       j = i+1;
     } finally { i=0; }
     return j+i;
   }

   public static void main(String[] argv) {
     System.out.println(m(5));
   }
}
