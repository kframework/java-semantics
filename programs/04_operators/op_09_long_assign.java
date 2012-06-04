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

		vs[i++] = "9L  =   3L";
		vs[i++] = "9L +=   3L";
		vs[i++] = "9L -=   3L";
		vs[i++] = "9L *=   3L";
		vs[i++] = "9L /=   3L";
		vs[i++] = "9L &=   3L";
		vs[i++] = "9L |=   3L";
		vs[i++] = "9L ^=   3L";
		vs[i++] = "9L %=   3L";
		vs[i++] = "9L <<=  3L";
		vs[i++] = "9L >>=  3L";
		vs[i++] = "9L >>>= 3L";

    return vs;
  }

	main(String[] args) {
    long[] v = new long[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 9L;
    }
    int i=0;

		v[i++] =  3L;
		v[i++] += 3L;
		v[i++] -= 3L;
		v[i++] *= 3L;
		v[i++] /= 3L;
		v[i++] &= 3L;
		v[i++] |= 3L;
		v[i++] ^= 3L;
		v[i++] %= 3L;
		v[i++] <<= 3L;
		v[i++] >>= 3L;
		v[i++] >>>= 3L;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_09_long_assign {
  public static void main(String[] args) {
    new main(args);
  }
}
