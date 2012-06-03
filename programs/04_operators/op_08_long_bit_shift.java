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

		vs[i++] = " 4L <<   1L    ";
		vs[i++] = " 4L <<  -1L    ";
		vs[i++] = "-4L <<   1L    ";
		vs[i++] = "-4L <<  -1L    ";
		vs[i++] = " 4L  >>  1L    ";
		vs[i++] = " 4L  >> -1L    ";
		vs[i++] = "-4L  >>  1L    ";
		vs[i++] = "-4L  >> -1L    ";
		vs[i++] = " 4L >>>  1L    ";
		vs[i++] = " 4L >>> -1L    ";
		vs[i++] = "-4L >>>  1L    ";
		vs[i++] = "-4L >>> -1L    ";

    return vs;
  }

	main(String[] args) {
    long[] v = new long[nrOps];
    String[] vs = initVS();
    int i=0;

		v[i++] =  4L <<   1L;
		v[i++] =  4L <<  -1L;
		v[i++] = -4L <<   1L;
		v[i++] = -4L <<  -1L;
		v[i++] =  4L  >>  1L;
		v[i++] =  4L  >> -1L;
		v[i++] = -4L  >>  1L;
		v[i++] = -4L  >> -1L;
		v[i++] =  4L >>>  1L;
		v[i++] =  4L >>> -1L;
		v[i++] = -4L >>>  1L;
		v[i++] = -4L >>> -1L;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_08_long_bit_shift {
  public static void main(String[] args) {
    new main(args);
  }
}
