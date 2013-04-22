class Test {
  static int m(int i) {
   try {
    return i+i;
   } finally {
    return i*i;
   }
  }

 static void main(String[] args) {
   System.out.println(m(3));
 }
}
