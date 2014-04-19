/*
White-box test. An interface field hides fields in one or more superinterfaces.
  Access the visible field via subinterface or subclass.
  Suppose that interface field resolving algorithm takes the set <implTrans>
  of implemented interfaces of the target class, and checks the presence of the field in them in the
  order in which they were added to the set.
  Can we desigh a test such that this behavior would be wrong, and we would need a list with strict
  order of implemented interface checking?
This problem don't appear in field hiding inside class, because the collection of superclasses is
  always a list. We have the problem with interfaces, because of multiple inheritance.
The only way to conceive this test is to have the "master itnerface" - the one with the field
  hiding other fields, indirectly implemented, with as many child interfaces as possible,
  and child interfaces should have names lexicographically both befor and after the master
  interface. Something like:

IA < (I1, I5, I9); I5 < I6; I6{v} < (I3, I7); I3{v} < (I2{v}, I4{v}); I7{v} < (I4{v}, I8{v})
  Access IA.v, I5.v, I6.v.
*/

public class interface_f_34_multi_inh_giga_hiding {
  public static void main(String[] args) {
    System.out.println(IA.v + " " + I5.v + " " +I6.v);
    System.out.println("Done!");
  }
}

interface I1 {}

interface I2 {
  int v = 2;
}

interface I3 extends I2, I4 {
  int v = 3;
}

interface I4 {
  int v = 4;
}

interface I5 extends I6 {}

interface I6 extends I3, I7 {
  int v = 6;
}

interface I7 extends I4, I8 {
  int v = 7;
}

interface I8 {
  int v = 8;
}

interface I9 {}

interface IA extends I1, I5, I9 {}
