public class Example3_2_1 {
  public static void main(String args[]) {
    int i = 4;
    l1: while(true) {
        System.out.println("l1: while");
        l2 : while(true) {
           System.out.println("l2: while");
           if (i==4) {
              System.out.println("continue l1");
              i = 3;
              continue l1;
           }
           if (i==3) {
              System.out.println("continue l2");
              i = 2;
              continue l2;
           }
           if (i==2) {
              System.out.println("break l2;");
              i = 1;
              break l2;
           }
           if (i==1) {
              System.out.println("break l1;");
              i = 0;
              break l1;
           }
        }
    }
  }
}
