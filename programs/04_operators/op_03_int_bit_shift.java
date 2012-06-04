class main {

	void printAll(String[] vs, int[] v) {
		for (int i = 0; i<v.length; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 12;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		vs[i++] = " 9 <<   2    ";
		vs[i++] = " 9 <<  -2    ";
		vs[i++] = "-9 <<   2    ";
		vs[i++] = "-9 <<  -2    ";
		vs[i++] = " 9  >>  2    ";
		vs[i++] = " 9  >> -2    ";
		vs[i++] = "-9  >>  2    ";
		vs[i++] = "-9  >> -2    ";
		vs[i++] = " 9 >>>  2    ";
		vs[i++] = " 9 >>> -2    ";
		vs[i++] = "-9 >>>  2    ";
		vs[i++] = "-9 >>> -2    ";

    return vs;
  }

	main(String[] args) {
    int[] v = new int[nrOps];
    String[] vs = initVS();
    int i=0;

		v[i++] =  9 <<   2;
		v[i++] =  9 <<  -2;
		v[i++] = -9 <<   2;
		v[i++] = -9 <<  -2;
		v[i++] =  9  >>  2;
		v[i++] =  9  >> -2;
		v[i++] = -9  >>  2;
		v[i++] = -9  >> -2;
		v[i++] =  9 >>>  2;
		v[i++] =  9 >>> -2;
		v[i++] = -9 >>>  2;
		v[i++] = -9 >>> -2;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_03_int_bit_shift {
  public static void main(String[] args) {
    new main(args);
  }
}
