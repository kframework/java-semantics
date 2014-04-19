class main {

	void printAllB(String[] vs, boolean[] v) {
		for (int i = 0; i<nrOps; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 6;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = "9 == 3       ";
		vs[i++] = "9 != 3       ";
		vs[i++] = "9 < 3        ";
		vs[i++] = "9 > 3        ";
		vs[i++] = "9 <= 3       ";
		vs[i++] = "9 >= 3       ";

    nrOps = i;

    return vs;
  }

	main(String[] args) {
    boolean[] vb = new boolean[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      vb[i] = false;
    }

    int i=0;
		//Infix operators
    vb[i++] = 9 == 3;
    vb[i++] = 9 != 3;
    vb[i++] = 9 < 3;
    vb[i++] = 9 > 3;
    vb[i++] = 9 <= 3;
    vb[i++] = 9 >= 3;

    printAllB(vs,vb);
    System.out.println("Done!");
	}
}

public class op_02_int_to_bool {
  public static void main(String[] args) {
    new main(args);
  }
}
