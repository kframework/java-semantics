class main {

	void printAll(String[] vs, long[] v) {
		for (int i = 0; i<nrOps; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 19;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = "4L | 2L        ";
		vs[i++] = "4L ^ 2L        ";
		vs[i++] = "4L & 2L        ";
		vs[i++] = "4L << 2L       ";
		vs[i++] = "4L >> 2L       ";
		vs[i++] = "4L >>> 2L      ";
		vs[i++] = "4L + 2L        ";
		vs[i++] = "4L - 2L        ";
		vs[i++] = "4L * 2L        ";
		vs[i++] = "4L / 2L        ";
		vs[i++] = "4L % 2L        ";

		//Prefix operators
		vs[i++] = "++4L          ";
		vs[i++] = "--4L          ";
		vs[i++] = "~ 4L          ";
		vs[i++] = "+ 4L          ";
		vs[i++] = "- 4L          ";

		//Postfix operators
		vs[i++] = "4L++          ";
		vs[i++] = "4L--          ";

    //Ternary operator
    vs[i++] = "4L > 2L ? 4L : 2L";

    return vs;
  }

	main(String[] args) {
    long[] v = new long[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 4L;
    }

    int i=0;
		//Infix operators
		v[i++] = 4L | 2L;
		v[i++] = 4L ^ 2L;
		v[i++] = 4L & 2L;
		v[i++] = 4L << 2L;
		v[i++] = 4L >> 2L;
		v[i++] = 4L >>> 2L;
		v[i++] = 4L + 2L;
		v[i++] = 4L - 2L;
		v[i++] = 4L * 2L;
		v[i++] = 4L / 2L;
		v[i++] = 4L % 2L;

		//Prefix operators
		++v[i++];
		--v[i++];
		v[i++] = ~ 4L;
		v[i++] = + 4L;
		v[i++] = - 4L;

		//Postfix operators
		v[i] = v[i++]++;
		v[i] = v[i++]--;

    //Ternary operator
    v[i++] = 4L > 2L ? 4L : 2L;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_06_long_to_long {
  public static void main(String[] args) {
    new main(args);
  }
}
