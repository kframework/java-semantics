package ro.uaic.javasemantics.tools;

import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Date: 23.05.2012
 *
 * @author denis.bogdanas@gmail.com
 */
public class Main {

  /**
   * see help.txt
   */
  public static void main(String[] args) {
    if (args.length == 1 && args[0].equals("-help")) {
      showHelp();
    } else {
      RunnerArgs runnerArgs = new RunnerArgs(args);
      new TestRunner(runnerArgs).run();
    }
  }

  private static void showHelp() {
    try {
      String help = TestRunner.readStream(new InputStreamReader(
          Main.class.getClassLoader().getResourceAsStream("help.txt")));
      System.out.println(help);
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }
}
