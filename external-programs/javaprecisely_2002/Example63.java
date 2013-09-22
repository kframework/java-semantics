// Example 63 from page 47 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example63 {
  public static void main(String[] args) {  
    if (args.length != 1) 
      System.out.println("Usage: java Example63 <string>\n");
    else {
      String q = args[0];
      System.out.println(q + " substring of hjsdfk: " + substring1(q, "hjsdfk"));
    }
  }

  // Decide whether query is a substring of target (using continue)

  static boolean substring1(String query, String target) {
    nextposition: 
      for (int j=0; j<=target.length()-query.length(); j++) {
        for (int k=0; k<query.length(); k++) 
          if (target.charAt(j+k) != query.charAt(k))
            continue nextposition;
        return true;
      }
    return false;
  }
}

