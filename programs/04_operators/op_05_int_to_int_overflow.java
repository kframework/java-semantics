class main {

	void printAll(String[] vs, int[] v) {
		for (int i = 0; i<nrOps; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 19;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = " 2147483647 + 2147483647      ";
		vs[i++] = "-2147483647 - 2147483647      ";
		vs[i++] = " 2147483647 * 2147483647      ";

    nrOps = i;

    return vs;
  }

	main(String[] args) {
    int[] v = new int[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 4;
    }

    int i=0;
		//Infix operators
		v[i++] =  2147483647 + 2147483647;
		v[i++] = -2147483647 - 2147483647;
		v[i++] =  2147483647 * 2147483647;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_05_int_to_int_overflow {
  public static void main(String[] args) {
    new main(args);
  }
}
