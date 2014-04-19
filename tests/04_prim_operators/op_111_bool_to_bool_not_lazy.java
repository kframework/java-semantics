public class op_111_bool_to_bool_not_lazy {
  public static void main(String[] args) {
    new main(args);
  }
}

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
		vs[i++] = "true | false ";
		vs[i++] = "true ^ false ";
		vs[i++] = "true & false ";
		vs[i++] = "true == false";
		vs[i++] = "true != false";

		//Prefix operators
		vs[i++] = "! true       ";

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
		vb[i++] = true | false;
		vb[i++] = true ^ false;
    vb[i++] = true & false;
    vb[i++] = true == false;
    vb[i++] = true != false;

		//Prefix operators
		vb[i++] = ! true;

    printAllB(vs,vb);
    System.out.println("Done!");
	}
}
