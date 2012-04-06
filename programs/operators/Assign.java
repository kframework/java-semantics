public class main {

	void printAll(string[] vs, int[] v) {
		for (int i = 0; i<v.length; i++) {
      print(vs[i],"  =>  ",v[i],"\n");
		}
	}

  int nrOps = 12;

  string[] initVS() {
    string[] vs = new string[nrOps];
    int i=0;

		vs[i++] = "4 = 2   ";
		vs[i++] = "4 +=   2";
		vs[i++] = "4 -=   2";
		vs[i++] = "4 *=   2";
		vs[i++] = "4 /=   2";
		vs[i++] = "4 &=   2";
		vs[i++] = "4 |=   2";
		vs[i++] = "4 ^=   2";
		vs[i++] = "4 %=   2";
		vs[i++] = "4 <<=  2";
		vs[i++] = "4 >>=  2";
		vs[i++] = "4 >>>= 2";

    return vs;
  }

	public static void main(string[] args) {
    int[] v = new int[nrOps];
    string[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 4;
    }
    int i=0;

		v[i++] = 2;
		v[i++] += 2;
		v[i++] -= 2;
		v[i++] *= 2;
		v[i++] /= 2;
		v[i++] &= 2;
		v[i++] |= 2;
		v[i++] ^= 2;
		v[i++] %= 2;
		v[i++] <<= 2;
		v[i++] >>= 2;
		v[i++] >>>= 2;

    printAll(vs,v);
	}
}
