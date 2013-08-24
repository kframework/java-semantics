/*
The rule [elabHeatDefault] in elaboration phase needs to heat expression terms from left to right only. Otherwise we will have problems with local variable declarations. Test: a simple main, declares a var on first line, writes a value to that variable on the second.
*/

public class mc_01_elabHeatDefault {
  public static void main(String[] args) {
    int a;
    a = 1;
  }
}
