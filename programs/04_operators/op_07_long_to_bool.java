class main {

	void printAllB(String[] vs, boolean[] v) {
		for (int i = 0; i<nrOps; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 14;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = "4L == 2L       ";
		vs[i++] = "4L != 2L       ";
		vs[i++] = "4L  < 2L       ";
		vs[i++] = "4L  > 2L       ";
		vs[i++] = "4L <= 2L       ";
		vs[i++] = "4L >= 2L       ";

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
    vb[i++] = 4L == 2L;
    vb[i++] = 4L != 2L;
    vb[i++] = 4L  < 2L;
    vb[i++] = 4L  > 2L;
    vb[i++] = 4L <= 2L;
    vb[i++] = 4L >= 2L;

    printAllB(vs,vb);
    System.out.println("Done!");
	}
}

public class op_07_long_to_bool {
  public static void main(String[] args) {
    new main(args);
  }
}
