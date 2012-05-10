public class main {
  void main(String[] args) {
    int x = 1;
    try { x = x + 1; throw x; x = x/0;}     // division by zero unreachable
    catch(int y) {x = y+1;}
    System.out.println(x);
    System.out.println("Done!");
  }
}
// 3
// Done!
