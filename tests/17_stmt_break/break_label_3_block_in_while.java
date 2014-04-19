// Test with one label, one labeled break, all inside while.
// Due to a bug in k definition, there was a strange interaction
// between labeled break and loops.
public class break_label_3_block_in_while {
  public static void main(String[] args) {
    int i=0, a=0;
    while(i<3) {
      label_1: {
        System.out.print("Before break "+ i+ ", ");
        if (true) break label_1;
        System.out.print("unreachable");
      }
      System.out.println("after break "+ i);
      i++;
    }
    System.out.println("Done!");
  }
}
// Before break 0, after break 0
// Before break 1, after break 1
// Before break 2, after break 2
// Done!
