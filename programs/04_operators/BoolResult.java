class main {

	void printAllB(String[] vs, boolean[] v) {
		for (int i = 0; i<v.length; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 14;

  String[] initVS() {
    String[] vs = new String[nrOps];
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

	main(String[] args) {
    boolean[] vb = new boolean[nrOps];
    String[] vs = initVS();

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
    System.out.println("Done!");
	}
}

public class BoolResult {
  public static void main(String[] args) {
    new main(args);
  }
}
