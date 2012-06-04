class main {

	void printAll(String[] vs, long[] v) {
		for (int i = 0; i<nrOps; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 30;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = "9L | 3L        ";
		vs[i++] = "9L ^ 3L        ";
		vs[i++] = "9L & 3L        ";
		vs[i++] = "9L | -4L       ";
		vs[i++] = "9L ^ -4L       ";
		vs[i++] = "9L & -4L       ";
		vs[i++] = "-10L | 3L      ";
		vs[i++] = "-10L ^ 3L      ";
		vs[i++] = "-10L & 3L      ";
		vs[i++] = "9L << 3L       ";
		vs[i++] = "9L >> 3L       ";
		vs[i++] = "9L >>> 3L      ";
		vs[i++] = "9L + 3L        ";
		vs[i++] = "9L - 3L        ";
		vs[i++] = "9L * 3L        ";
		vs[i++] = "9L / 3L        ";
		vs[i++] = "9L % 3L        ";

		//Prefix operators
		vs[i++] = "++9L          ";
		vs[i++] = "--9L          ";
		vs[i++] = "~ 9L          ";
		vs[i++] = "+ 9L          ";
		vs[i++] = "- 9L          ";

		//Postfix operators
		vs[i++] = "9L++          ";
		vs[i++] = "9L--          ";

    //Ternary operator
    vs[i++] = "9L > 3L ? 9L : 3L";

    nrOps = i;
    return vs;
  }

	main(String[] args) {
    long[] v = new long[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 9L;
    }

    int i=0;
		//Infix operators
		v[i++] = 9L | 3L;
		v[i++] = 9L ^ 3L;
		v[i++] = 9L & 3L;
		v[i++] = 9L | -4L;
		v[i++] = 9L ^ -4L;
		v[i++] = 9L & -4L;
		v[i++] = -10L | 3L;
		v[i++] = -10L ^ 3L;
		v[i++] = -10L & 3L;
		v[i++] = 9L << 3L;
		v[i++] = 9L >> 3L;
		v[i++] = 9L >>> 3L;
		v[i++] = 9L + 3L;
		v[i++] = 9L - 3L;
		v[i++] = 9L * 3L;
		v[i++] = 9L / 3L;
		v[i++] = 9L % 3L;

		//Prefix operators
		++v[i++];
		--v[i++];
		v[i++] = ~ 9L;
		v[i++] = + 9L;
		v[i++] = - 9L;

		//Postfix operators
		v[i] = v[i++]++;
		v[i] = v[i++]--;

    //Ternary operator
    v[i++] = 9L > 3L ? 9L : 3L;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_06_long_to_long {
  public static void main(String[] args) {
    new main(args);
  }
}
