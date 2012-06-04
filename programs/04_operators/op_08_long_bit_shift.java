class main {

	void printAll(String[] vs, long[] v) {
		for (int i = 0; i<v.length; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 12;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		vs[i++] = " 9L <<   2L    ";
		vs[i++] = " 9L <<  -2L    ";
		vs[i++] = "-9L <<   2L    ";
		vs[i++] = "-9L <<  -2L    ";
		vs[i++] = " 9L  >>  2L    ";
		vs[i++] = " 9L  >> -2L    ";
		vs[i++] = "-9L  >>  2L    ";
		vs[i++] = "-9L  >> -2L    ";
		vs[i++] = " 9L >>>  2L    ";
		vs[i++] = " 9L >>> -2L    ";
		vs[i++] = "-9L >>>  2L    ";
		vs[i++] = "-9L >>> -2L    ";

    return vs;
  }

	main(String[] args) {
    long[] v = new long[nrOps];
    String[] vs = initVS();
    int i=0;

		v[i++] =  9L <<   2L;
		v[i++] =  9L <<  -2L;
		v[i++] = -9L <<   2L;
		v[i++] = -9L <<  -2L;
		v[i++] =  9L  >>  2L;
		v[i++] =  9L  >> -2L;
		v[i++] = -9L  >>  2L;
		v[i++] = -9L  >> -2L;
		v[i++] =  9L >>>  2L;
		v[i++] =  9L >>> -2L;
		v[i++] = -9L >>>  2L;
		v[i++] = -9L >>> -2L;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_08_long_bit_shift {
  public static void main(String[] args) {
    new main(args);
  }
}
