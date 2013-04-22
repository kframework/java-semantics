public class A {
  static public void main(String args[]) {
    int i = 5;
    int j = 0;
    while (((i%2)!=0)) {
      i = (i/2);
      j = (j+1);
    }
    System.out.println(i);
    System.out.println(j);
  }
}
