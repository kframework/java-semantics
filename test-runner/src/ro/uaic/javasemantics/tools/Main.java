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
  public static void main(final String[] args) {
    if (args.length == 1 && args[0].equals("-help")) {
      showHelp();
    } else {
      final Thread mainThread = new Thread(new Runnable() {
        @Override
        public void run() {
          RunnerArgs runnerArgs = new RunnerArgs(args);
          new TestRunner(runnerArgs).run();
        }
      });

      Runtime.getRuntime().addShutdownHook(new Thread() {
        @Override
        public void run() {
          try {
            mainThread.interrupt();
            mainThread.join();
          } catch (InterruptedException e) {
            //ignored
          }
        }
      });

      mainThread.start();
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
