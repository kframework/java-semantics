class main {

	void printAll(String[] vs, long[] v) {
		for (int i = 0; i<v.length; i++) {
      System.out.println(vs[i]+"  =>  "+v[i]);
		}
	}

  int nrOps = 12;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		vs[i++] = "4L  =   2L";
		vs[i++] = "4L +=   2L";
		vs[i++] = "4L -=   2L";
		vs[i++] = "4L *=   2L";
		vs[i++] = "4L /=   2L";
		vs[i++] = "4L &=   2L";
		vs[i++] = "4L |=   2L";
		vs[i++] = "4L ^=   2L";
		vs[i++] = "4L %=   2L";
		vs[i++] = "4L <<=  2L";
		vs[i++] = "4L >>=  2L";
		vs[i++] = "4L >>>= 2L";

    return vs;
  }

	main(String[] args) {
    long[] v = new long[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 4L;
    }
    int i=0;

		v[i++] =  2L;
		v[i++] += 2L;
		v[i++] -= 2L;
		v[i++] *= 2L;
		v[i++] /= 2L;
		v[i++] &= 2L;
		v[i++] |= 2L;
		v[i++] ^= 2L;
		v[i++] %= 2L;
		v[i++] <<= 2L;
		v[i++] >>= 2L;
		v[i++] >>>= 2L;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_09_long_assign {
  public static void main(String[] args) {
    new main(args);
  }
}
