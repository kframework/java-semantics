/*
Array instanceof:
  Object NPE[] instanceof RE[]
  Object RE[] instanceof NPE[]
  RE[] NPE[] instanceof NPE[]
  RE[] NPE[] instanceof CCE[]
  Object int[] instanceof int[]
  Object int[] instanceof long[]
  Object long[] instanceof int[]
*/

public class array_20_instanceof {

  public static void main(String[] args) {
    Object vnpe = new NullPointerException[0];
    System.out.println(vnpe instanceof RuntimeException[]);

    Object vre = new RuntimeException[0];
    System.out.println(vre instanceof NullPointerException[]);

    RuntimeException[] renpe = new NullPointerException[0];
    System.out.println(renpe instanceof NullPointerException[]);
    System.out.println(renpe instanceof ClassCastException[]);

    Object vint = new int[0];
    System.out.println(vint instanceof int[]);
    System.out.println(vint instanceof long[]);

    Object vlong = new long[0];
    System.out.println(vlong instanceof int[]);

    System.out.println("Done!");
  }
}
