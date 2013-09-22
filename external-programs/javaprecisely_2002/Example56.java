// Example 56 from page 43 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example56 {
  public static void main(String[] args) {
    System.out.println("44 is " + findCountry(44));
  }

  static String findCountry(int prefix) {
    switch (prefix) {
    case 1:   return "North America";
    case 44:  return "Great Britain";
    case 45:  return "Denmark";
    case 299: return "Greenland";
    case 46:  return "Sweden";
    case 7:   return "Russia";
    case 972: return "Israel";
    default:  return "Unknown";
    }
  }
}

