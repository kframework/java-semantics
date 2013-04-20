public class op_014_int_to_int_bin_arith {
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

  int nrOps = 5;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = "9 + 3        ";
		vs[i++] = "9 - 3        ";
		vs[i++] = "9 * 3        ";
		vs[i++] = "9 / 3        ";
		vs[i++] = "9 % 3        ";

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
		//Infix operators
		v[i++] = 9 + 3;
		v[i++] = 9 - 3;
		v[i++] = 9 * 3;
		v[i++] = 9 / 3;
		v[i++] = 9 % 3;

    printAll(vs,v);
    System.out.println("Done!");
	}
}
