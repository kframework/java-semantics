public class main {

	void printAll(string[] vs, int[] v) {
		for (int i = 0; i<v.length; i++) {
      print(vs[i]," = ",v[i],"\n");
		}
	}

  int nrOps = 19;

  string[] initVS() {
    string[] vs = new string[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = "4 | 2        ";
		vs[i++] = "4 ^ 2        ";
		vs[i++] = "4 & 2        ";
		vs[i++] = "4 << 2       ";
		vs[i++] = "4 >> 2       ";
		vs[i++] = "4 >>> 2      ";
		vs[i++] = "4 + 2        ";
		vs[i++] = "4 - 2        ";
		vs[i++] = "4 * 2        ";
		vs[i++] = "4 / 2        ";
		vs[i++] = "4 % 2        ";

		//Prefix operators
		vs[i++] = "++4          ";
		vs[i++] = "--4          ";
		vs[i++] = "~ 4          ";
		vs[i++] = "+ 4          ";
		vs[i++] = "- 4          ";

		//Postfix operators
		vs[i++] = "4++          ";
		vs[i++] = "4--          ";

    //Ternary operator
    vs[i++] = "4 > 2 ? 4 : 2";

    return vs;
  }

	public static void main(string[] args) {
    int[] v = new int[nrOps];
    string[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 4;
    }

    int i=0;
		//Infix operators
		v[i++] = 4 | 2;
		v[i++] = 4 ^ 2;
		v[i++] = 4 & 2;
		v[i++] = 4 << 2;
		v[i++] = 4 >> 2;
		v[i++] = 4 >>> 2;
		v[i++] = 4 + 2;
		v[i++] = 4 - 2;
		v[i++] = 4 * 2;
		v[i++] = 4 / 2;
		v[i++] = 4 % 2;

		//Prefix operators
		++v[i++];
		--v[i++];
		v[i++] = ~ 4;
		v[i++] = + 4;
		v[i++] = - 4;

		//Postfix operators
		v[i] = v[i++]++;
		v[i] = v[i++]--;

    //Ternary operator
    v[i++] = 4 > 2 ? 4 : 2;

    printAll(vs,v);
	}
}
