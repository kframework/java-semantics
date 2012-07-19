// JLS $15.26.2
// The example was heavily cleaned up to be compatible with supported java semantics features.
// Especially the code related to double vars have been removed.
//currently fails because JVM exceptions have not been implemented yet.

class ArrayReferenceThrow extends RuntimeException {
  ArrayReferenceThrow() {
    super((String) null);
  }
}
class IndexThrow extends RuntimeException {
  IndexThrow() {
    super((String) null);
  }
}
class RightHandSideThrow extends RuntimeException {
  RightHandSideThrow() {
    super((String) null);
  }
}

class IllustrateCompoundArrayAssignment {
  String[] strings;

  IllustrateCompoundArrayAssignment() {
    strings = new String[2];
    strings[0] = "Simon";
    strings[1] = "Garfunkel";
  }
  String[] stringsThrow() {
    throw new ArrayReferenceThrow();
  }
  int indexThrow() { throw new IndexThrow(); }
  String stringThrow() {
    throw new RightHandSideThrow();
  }
  void testEight(String[] x, int j) {
    String sx = (x == null) ? "null" : "Strings";
    System.out.println();
    try {
      System.out.print(sx + "[throw]+=throw => ");
      x[indexThrow()] += stringThrow();
      System.out.println("Okay!");
    } catch (RuntimeException e) { System.out.println(e); }
    try {
      System.out.print(sx + "[throw]+=\"heh\" => ");
      x[indexThrow()] += "heh";
      System.out.println("Okay!");
    } catch (RuntimeException e) { System.out.println(e); }
    try {
      System.out.print(sx + "[" + j + "]+=throw => ");
      x[j] += stringThrow();
      System.out.println("Okay!");
    } catch (RuntimeException e) { System.out.println(e); }
    try {
      System.out.print(sx + "[" + j + "]+=\"heh\" => ");
      x[j] += "heh";
      System.out.println("Okay!");
    } catch (RuntimeException e) { System.out.println(e); }
  }

  void main() {
    try {
      System.out.print("throw[throw]+=throw => ");
      stringsThrow()[indexThrow()] += stringThrow();
      System.out.println("Okay!");
    } catch (RuntimeException e) { System.out.println(e); }
    try {
      System.out.print("throw[throw]+=\"heh\" => ");
      stringsThrow()[indexThrow()] += "heh";
      System.out.println("Okay!");
    } catch (RuntimeException e) { System.out.println(e); }
    try {
      System.out.print("throw[1]+=throw => ");
      stringsThrow()[1] += stringThrow();
      System.out.println("Okay!");
    } catch (RuntimeException e) { System.out.println(e); }
    try {
      System.out.print("throw[1]+=\"heh\" => ");
      stringsThrow()[1] += "heh";
      System.out.println("Okay!");
    } catch (RuntimeException e) { System.out.println(e); }

    testEight(null, 1);
    testEight(null, 9);
    testEight(strings, 1);
    testEight(strings, 9);
  }
}

public class op_13_compound_assign_jls {
  public static void main(String[] args) {
    //new IllustrateCompoundArrayAssignment().main();
  }
}
