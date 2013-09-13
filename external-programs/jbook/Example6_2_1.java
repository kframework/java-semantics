class Example6_2_1 {
  static int m(int i) {
   try {
    return i+i;
   } finally {
    return i*i;
   }
  }

 public static void main(String[] args) {
   System.out.println(m(3));
 }
}
