public class main {

	void printAll(string[] vs, int[] v) {
		for (int i = 0; i<v.length; i++) {
      print(vs[i]," = ",v[i],"\n");
		}
	}

  int nrOps = 12;

  string[] initVS() {
    string[] vs = new string[nrOps];
    int i=0;

		vs[i++] = " 4 <<   1    ";
		vs[i++] = " 4 <<  -1    ";
		vs[i++] = "-4 <<   1    ";
		vs[i++] = "-4 <<  -1    ";
		vs[i++] = " 4  >>  1    ";
		vs[i++] = " 4  >> -1    ";
		vs[i++] = "-4  >>  1    ";
		vs[i++] = "-4  >> -1    ";
		vs[i++] = " 4 >>>  1    ";
		vs[i++] = " 4 >>> -1    ";
		vs[i++] = "-4 >>>  1    ";
		vs[i++] = "-4 >>> -1    ";

    return vs;
  }

	public static void main(string[] args) {
    int[] v = new int[nrOps];
    string[] vs = initVS();
    int i=0;

		v[i++] =  4 <<   1;
		v[i++] =  4 <<  -1;//different from java due to overflow
		v[i++] = -4 <<   1;
		v[i++] = -4 <<  -1;//different from java due to overflow
		v[i++] =  4  >>  1;
		v[i++] =  4  >> -1;
		v[i++] = -4  >>  1;
		v[i++] = -4  >> -1;
		v[i++] =  4 >>>  1;
		v[i++] =  4 >>> -1;
		v[i++] = -4 >>>  1;
		v[i++] = -4 >>> -1;

    printAll(vs,v);
    print("Done!", "\n");
	}
}
