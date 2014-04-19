/*
Class resolution in cast.
  Classes p1.A, p2.A. Main CU imports p2.A.
  - Object o1 = new p1.A
  - Object o2 = new p2.A
  - Test cast of both objects to A, p1.A, p2.A.
*/

import p2.A;

public class packages_58_fullyqual_cast {

  public static void main(String[] args) {
    Object oa1 = new p1.A();
    Object oa2 = new p2.A();
    try {
      A a = (A) oa1;
      System.out.println("(   A) oa1 ok");
    } catch (RuntimeException e) {
      System.out.println("(   A) oa1 failed");
    }
    try {
      p1.A a = (p1.A) oa1;
      System.out.println("(p1.A) oa1 ok");
    } catch (RuntimeException e) {
      System.out.println("(p1.A) oa1 failed");
    }
    try {
      p2.A a = (p2.A) oa1;
      System.out.println("(p2.A) oa1 ok");
    } catch (RuntimeException e) {
      System.out.println("(p2.A) oa1 failed");
    }
    try {
      A a = (A) oa2;
      System.out.println("(   A) oa2 ok");
    } catch (RuntimeException e) {
      System.out.println("(   A) oa2 failed");
    }
    try {
      p1.A a = (p1.A) oa2;
      System.out.println("(p1.A) oa2 ok");
    } catch (RuntimeException e) {
      System.out.println("(p1.A) oa2 failed");
    }
    try {
      p2.A a = (p2.A) oa2;
      System.out.println("(p2.A) oa2 ok");
    } catch (RuntimeException e) {
      System.out.println("(p2.A) oa2 failed");
    }

    System.out.println("Done!");
  }
}

