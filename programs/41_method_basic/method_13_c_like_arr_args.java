// Method with c-like array arguments. Three such arguments.

public class method_13_c_like_arr_args {
  public static void main(String[] args) {
    new A().f(new int[]{1,2,3}, new String[]{"12",null}, new int[][]{null,null,null,{1,2}});
    System.out.println("Done!");
  }
}

class A {
  void f(int vi[], String vs[], int mi[][]) {
    System.out.println("vi.length= "+vi.length);
    System.out.println("vs.length= "+vs.length);
    System.out.println("mi.length= "+mi.length);
  }
}
