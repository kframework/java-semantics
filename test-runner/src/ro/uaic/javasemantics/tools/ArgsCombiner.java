package ro.uaic.javasemantics.tools;

import java.util.ArrayList;
import java.util.List;

/**
 * Combine arguments between quotes. E.g. "x y" will be combined into one single argument.
 */
public class ArgsCombiner {

  public static List<String> combine(List<String> rawArgs) {
    List<String> result = new ArrayList<>();
    boolean openQuote = false;
    String str = null;
    for(String rawArg: rawArgs) {
      if (openQuote) {
        str += " " + rawArg;
        if (rawArg.endsWith("\"")) {
          openQuote = false;
          result.add(str);
          str = null;
        }
      } else {
        if (rawArg.startsWith("\"") && !rawArg.endsWith("\"")) {
          openQuote = true;
          str = rawArg;
        } else {
          result.add(rawArg);
        }
      }
    }
    return result;
  }
}
