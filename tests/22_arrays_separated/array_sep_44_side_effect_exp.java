/*
Array expressions with side effects.
  v[0]++;
  v[1]--;
  ++v[2];
  --v[3];
  v[4]+=5;
*/

public class array_sep_44_side_effect_exp {

  public static void main(String[] args) {
    int[] v = new int[2];
    for(int i=0; i<2; i++) {
      v[i] = 10;
    }
    v[0]++;
    v[1]--;
    for(int i=0; i<2; i++) {
      System.out.print(v[i] + " ");
    }
    System.out.println();
    System.out.println("Done!");
  }
}
