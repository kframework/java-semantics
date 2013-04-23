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

class A {}
class B extends A{}
class C extends B{}

public class array_sep_20_instanceof {

  public static void main(String[] args) {
    A[] renpe = new B[0];
    System.out.println(renpe instanceof B[]);
    System.out.println(renpe instanceof C[]);

    System.out.println("Done!");
  }
}
