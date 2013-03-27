package ro.uaic.javasemantics.tools;

import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Platform;

import java.io.IOException;
import java.lang.reflect.Field;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Denis Bogdanas
 *         Date: 3/27/13
 */
public class ProcessUtil {

  static interface Kernel32 extends Library {

    public static Kernel32 INSTANCE = (Kernel32) Native.loadLibrary("kernel32", Kernel32.class);

    public int GetProcessId(Long hProcess);
  }

  public static int getPid(Process process) {
    Field handleField;

    if (Platform.isWindows()) {
      try {
        handleField = process.getClass().getDeclaredField("handle");
        handleField.setAccessible(true);
        int pid = Kernel32.INSTANCE.GetProcessId((Long) handleField.get(process));
        return pid;
      } catch (Exception ex) {
        Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
      }
    } else if (Platform.isLinux()) {
      try {
        handleField = process.getClass().getDeclaredField("pid");
        handleField.setAccessible(true);
        int pid = (Integer) handleField.get(process);
        return pid;
      } catch (Exception ex) {
        Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
      }
    } else {
    }
    return 0;
  }

  public static void forcedKillProcessTree(Process process, boolean waitForCompletion)
      throws IOException, InterruptedException {
    int pid = getPid(process);
    if (Platform.isWindows()) {
      Process killProcess = Runtime.getRuntime().exec("taskkill /pid " + pid + " /f /t");
      if (waitForCompletion) {
        killProcess.waitFor();
      }
    } else {
      throw new UnsupportedOperationException("Unsupported for the current operating system");
    }
  }

  /**
   * Works only on Windows
   */
  public static void killProcessTree(Process process, boolean waitForCompletion)
      throws IOException, InterruptedException {
    int pid = getPid(process);
    if (Platform.isWindows()) {
      Process killProcess = Runtime.getRuntime().exec("taskkill /pid " + pid + " /t");
      if (waitForCompletion) {
        killProcess.waitFor();
      }
    } else {
      throw new UnsupportedOperationException("Unsupported for the current operating system");
    }
  }
}
