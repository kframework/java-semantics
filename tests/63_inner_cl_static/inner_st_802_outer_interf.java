/*
Outer interface. Interface I1, class I1.InnerC, interface I1.InnerI.
  Both access a static field from A by simple name.
*/

public class inner_st_802_outer_interf {

  public static void main(String[] args) {
    System.out.println(I1.InnerC.cid);
    System.out.println(I1.InnerI.iid);

    System.out.println("Done!");
  }
}

interface I1 {

  String outerid = "I1.outerid";

  static class InnerC {
    static String cid = "InnerC.cid: " + outerid;
  }

  static interface InnerI {
    String iid = "InnerI.iid: " + outerid;
  }
}

