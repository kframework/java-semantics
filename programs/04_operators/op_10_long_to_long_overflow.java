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
		vs[i++] = " 9223372036854775807L + 9223372036854775807L      ";
		vs[i++] = "-9223372036854775807L - 9223372036854775807L      ";
		vs[i++] = " 9223372036854775807L * 9223372036854775807L      ";

    nrOps = i;

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
		v[i++] =  9223372036854775807L + 9223372036854775807L;
		v[i++] = -9223372036854775807L - 9223372036854775807L;
		v[i++] =  9223372036854775807L * 9223372036854775807L;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_10_long_to_long_overflow {
  public static void main(String[] args) {
    new main(args);
  }
}
