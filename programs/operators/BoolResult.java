public class main {

	void printAllB(string[] vs, boolean[] v) {
		for (int i = 0; i<v.length; i++) {
      print(vs[i]," = ",v[i],"\n");
		}
	}

  int nrOps = 14;

  string[] initVS() {
    string[] vs = new string[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = "true || false";
		vs[i++] = "true && false";
		vs[i++] = "true | false ";
		vs[i++] = "true ^ false ";
		vs[i++] = "true & false ";
		vs[i++] = "true == false";
		vs[i++] = "true != false";
		vs[i++] = "4 == 2       ";
		vs[i++] = "4 != 2       ";
		vs[i++] = "4 < 2        ";
		vs[i++] = "4 > 2        ";
		vs[i++] = "4 <= 2       ";
		vs[i++] = "4 >= 2       ";

		//Prefix operators
		vs[i++] = "! true       ";

    return vs;
  }

	public static void main(string[] args) {
    boolean[] vb = new boolean[nrOps];
    string[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      vb[i] = false;
    }

    int i=0;
		//Infix operators
		vb[i++] = true || false;
		vb[i++] = true && false;
		vb[i++] = true | false;
		vb[i++] = true ^ false;
    vb[i++] = true & false;
    vb[i++] = true == false;
    vb[i++] = true != false;
    vb[i++] = 4 == 2;
    vb[i++] = 4 != 2;
    vb[i++] = 4 < 2;
    vb[i++] = 4 > 2;
    vb[i++] = 4 <= 2;
    vb[i++] = 4 >= 2;

		//Prefix operators
		vb[i++] = ! true;

    printAllB(vs,vb);
	}
}
