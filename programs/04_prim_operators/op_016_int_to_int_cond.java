public class op_016_int_to_int_cond {
  public static void main(String[] args) {
    new main(args);
  }
}

class main {

	void printAll(String[] vs, int[] v) {
		for (int i = 0; i<nrOps; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 1;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

    //Ternary operator
    vs[i++] = "9 > 3 ? 9 : 3";

    nrOps = i;
    return vs;
  }

	main(String[] args) {
    int[] v = new int[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 9;
    }

    int i=0;

    //Ternary operator
    v[i++] = 9 > 3 ? 9 : 3;

    printAll(vs,v);
    System.out.println("Done!");
	}
}
