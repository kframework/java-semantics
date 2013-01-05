package ro.uaic.javasemantics.tools;

import java.io.*;
import java.nio.CharBuffer;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.*;

/**
 * Date: 23.05.2012
 *
 * @author denis.bogdanas@gmail.com
 */
@SuppressWarnings("ConstantConditions")
public class TestRunner {
  private RunnerArgs args;
  private ExecutorService processExecutor;

  public TestRunner(RunnerArgs args) {
    this.args = args;
  }

  public void run() {
    String userDir = System.getProperty("user.dir");
    File runDir = new File(userDir, ".test").getAbsoluteFile();
    if (args.isClean()) {
      deleteDir(runDir);
    }
    mkdirs(runDir);

    ExecutorService executor = newExecutorService();
    processExecutor = newExecutorService();
    List<Future<TestResult>> results = new ArrayList<Future<TestResult>>();

    try {
      boolean createDir = args.getTargetFileDirs().size() > 1 ||
          isTest(new File(args.getTargetFileDirs().get(0)));
      for (String testProg : args.getTargetFileDirs()) {
        gatherTasks(runDir, new File(testProg), createDir, results, executor);
      }

      new XmlBuilder(args, results).buildXml();
    } finally {
      executor.shutdown();
      processExecutor.shutdown();
    }
  }

  private void mkdirs(File dir) {
    try {
      Files.createDirectories(dir.toPath());
    } catch (IOException e) {
      throw new RuntimeException("Cannot create temp directory: " + dir, e);
    }
  }

  private ThreadPoolExecutor newExecutorService() {
    return new ThreadPoolExecutor(args.getThreads(), args.getThreads(),
        Long.MAX_VALUE, TimeUnit.SECONDS,
        new LinkedBlockingQueue<Runnable>());
  }

  private void deleteDir(File dir) {
    if (args.getRemoveScript() != null) {
      deleteUsingScript(args.getRemoveScript(), dir);
    } else {
      delete(dir);
    }
  }

  private static void delete(File f) {
    if (!f.exists()) {
      return;
    }
    if (f.isDirectory()) {
      for (File c : f.listFiles()) {
        delete(c);
      }
    }
    try {
      Files.delete(f.toPath());
    } catch (IOException e) {
      throw new RuntimeException("Failed to delete file: " + f, e);
    }
  }

  private void deleteUsingScript(String removeScript, File f) {
    try {
      Process proc =
          Runtime.getRuntime().exec(new String[]{removeScript, f.toString()});
      proc.waitFor();
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  private void gatherTasks(File runParent, File target, boolean createDir,
                           List<Future<TestResult>> results,
                           ExecutorService executor) {
    File targetRunDir;
    if (createDir) {
      String targetDirName =
          isTest(target) ? "." + getNameWithoutExt(target.getName()) :
              target.getName();
      targetRunDir = new File(runParent, targetDirName);
    } else {
      targetRunDir = runParent;
    }
    if (isTest(target)) {
      results.add(executor.submit(new Task(targetRunDir, target)));
    } else {
      File[] children = target.listFiles(new TestFileFilter());
      Arrays.sort(children);
      for (File child : children) {
        gatherTasks(targetRunDir, child, true, results, executor);
      }
    }
  }

  private boolean isTest(File target) {
    return target.isFile() || (args.getTaskExt() != null &&
        target.getName().endsWith("." + args.getTaskExt()));
  }

  private static String getExtension(String name) {
    int index = name.lastIndexOf('.');
    return index != -1 ? name.substring(index + 1, name.length()) : null;
  }

  private static String getNameWithoutExt(String name) {
    boolean lastNameHaveExt = getLastName(name).lastIndexOf('.') != -1;
    return lastNameHaveExt ? name.substring(0, name.lastIndexOf('.')) :
        name;
  }

  /**
   * @return the out file located in the same dir as the test file
   */
  private File getDefaultOut(File testFile) {
    String testNoExt = getNameWithoutExt(testFile.toString());
    return new File(testNoExt + "." + args.getExpectedOutExt());
  }

  /**
   * @return either the out file in the smae dir as the test, if exists, or the
   *         out in the temp dir
   */
  private File getTestExpectedOut(File runDir, File testFile) {
    File defaultOut = getDefaultOut(testFile);
    return defaultOut.exists() ? defaultOut :
        getCachedExpectedOut(runDir, testFile);
  }

  private File getCachedExpectedOut(File runDir, File testFile) {
    return new File(runDir.getParent(),
        getLastName(getDefaultOut(testFile).toString()));
  }

  private File getTestActualOut(File runDir, File testFile) {
    String testNoExt = getNameWithoutExt(testFile.toString());
    return new File(runDir.getParent(),
        getLastName(testNoExt) + "." + args.getActualOutExt());
  }

  private File getTestIn(File testFile) {
    String testNoExt = getNameWithoutExt(testFile.toString());
    return new File(testNoExt + "." + args.getInExt());
  }

  private File getGenErr(File runDir, File testFile) {
    String testNoExt = getNameWithoutExt(testFile.toString());
    return new File(runDir.getParent(),
        getLastName(testNoExt) + "." + args.getGenerrExt());
  }

  private File getTestErr(File runDir, File testFile) {
    String testNoExt = getNameWithoutExt(testFile.toString());
    return new File(runDir.getParent(),
        getLastName(testNoExt) + "." + args.getErrExt());
  }

  private File getComp(File runDir, File testFile) {
    String testNoExt = getNameWithoutExt(testFile.toString());
    return new File(runDir.getParent(),
        getLastName(testNoExt) + "." + args.getCompExt());
  }

  private static String getLastName(String path) {
    return new File(path).getName();
  }

  public static String readFile(File file) throws IOException {
    Reader reader = new FileReader(file);
    return readStream(reader);
  }

  public static String readStream(Reader reader) throws IOException {
    StringBuilder sb = new StringBuilder();
    CharBuffer buf = CharBuffer.allocate(1024);
    while (reader.read(buf) >= 0) {
      sb.append(buf.flip());
      buf.clear();
    }
    reader.close();
    return sb.toString();
  }

  public class Task implements Callable<TestResult> {

    private File runDir, target;

    public Task(File runDir, File target) {
      this.runDir = runDir;
      this.target = target;
    }

    @Override
    public TestResult call() throws Exception {
      long start = System.currentTimeMillis();
      TestResult result = new TestResult();
      result.setName(target.toString());

      File testFile = target.getAbsoluteFile();
      File generator = args.getGenerator() != null ?
          new File(args.getGenerator()).getAbsoluteFile() : null;
      File runner = args.getRunner() != null ?
          new File(args.getRunner()).getAbsoluteFile() : null;
      boolean goodExpectedOutExists =
          expectedOutExistsFromStart(runDir, testFile);

      taskLogic:
      {
        mkdirs(runDir);
        File testExpectedOut = getTestExpectedOut(runDir, testFile);
        if (generator != null &&
            (!goodExpectedOutExists || !args.isConditionalGenerator())) {
          File genErr = getGenErr(runDir, testFile);
          Future<Integer> future = processExecutor.submit(
              new ProcessCallable(runDir, generator, testFile,
                  getTestIn(testFile), testExpectedOut, genErr));
          try {
            future.get(getFutureTimeout(), TimeUnit.SECONDS);
          } catch (TimeoutException e) {
            future.cancel(true);
            result.setErrorMesage("Test generator timed out");
            break taskLogic;
          }
          if (genErr.length() != 0) {
            result.setGenerr(genErr);
            if (testExpectedOut.equals(getCachedExpectedOut(runDir, testFile))) {
              delete(testExpectedOut);
            }
          }
        }

        if (result.getGenerr() == null && runner != null) {
          File testActualOut = getTestActualOut(runDir, testFile);
          File testErr = getTestErr(runDir, testFile);
          Future<Integer> future = processExecutor.submit(
              new ProcessCallable(runDir, runner, testFile, getTestIn(testFile),
                  testActualOut, testErr));
          try {
            future.get(getFutureTimeout(), TimeUnit.SECONDS);
          } catch (TimeoutException e) {
            future.cancel(true);
            result.setErrorMesage("Test timed out");
            break taskLogic;
          }
          if (testErr.length() != 0) {
            result.setStderr(testErr);
          }
          String expectedOutContent;
          String actualOutContent;
          try {
            expectedOutContent = readFile(testExpectedOut);
            actualOutContent = readFile(testActualOut);
          } catch (IOException e) {
            throw new RuntimeException(e);
          }
          boolean passed = actualOutContent.equals(expectedOutContent);
          result.setSuccess(passed);
          if (!passed) {
            try {
              StringBuilder compBuilder = new StringBuilder();
              compBuilder.append("Expected output:\n\n");
              compBuilder.append(expectedOutContent);
              compBuilder.append("\nActual output:\n\n");
              compBuilder.append(actualOutContent);
              String comp = compBuilder.toString();
              result.setComp(comp);

              File compFile = getComp(runDir, testFile);
              PrintWriter diffWriter = new PrintWriter(compFile);
              diffWriter.print(comp);
              diffWriter.close();
            } catch (FileNotFoundException e) {
              throw new RuntimeException(e);
            }
          }
        } else {
          result.setSuccess(true);
        }
      }
      long end = System.currentTimeMillis();
      result.setTime(end - start);
      return result;
    }

    private long getFutureTimeout() {
      return args.getTimeout() > 0 ? args.getTimeout() : Long.MAX_VALUE;
    }

    private boolean expectedOutExistsFromStart(File runDir, File testFile) {
      if (getDefaultOut(testFile).exists()) {
        return true;
      }
      if (args.isSmartGen() && target.isFile()) {
        File outFile = getCachedExpectedOut(runDir, testFile);
        File inFile = getTestIn(testFile);
        boolean outExists = outFile.exists();
        if (outExists) {
          try {
            long testTime =
                Files.getLastModifiedTime(testFile.toPath()).toMillis();
            long outTime = outExists ?
                Files.getLastModifiedTime(outFile.toPath()).toMillis() : -1;

            boolean inExists = inFile.exists();
            long inTime = inExists ? Files
                .getLastModifiedTime(inFile.toPath()).toMillis() : -1;
            return testTime < outTime && (!inExists || inTime < outTime);
          } catch (IOException e) {
            throw new RuntimeException(e);
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
  }

  private class ProcessCallable implements Callable<Integer> {
    File processDir, runner, test, in, out, err;

    /**
     * All args are absolute paths
     */
    private ProcessCallable(File processDir, File runner, File test, File in,
                            File out, File err) {
      this.processDir = processDir;
      this.runner = runner;
      this.test = test;
      this.in = in;
      this.out = out;
      this.err = err;
    }

    @Override
    public Integer call() throws Exception {
      ProcessBuilder procBuilder = new ProcessBuilder();
      procBuilder.directory(processDir);
      procBuilder.command(runner.toString(), test.toString());
      boolean inFileExists = in.exists();
      if (inFileExists) {
        procBuilder.redirectInput(in);
      }
      procBuilder.redirectOutput(out);
      procBuilder.redirectError(err);

      Process process = procBuilder.start();
      if (!inFileExists) {
        process.getOutputStream().close();
      }
      try {
        process.waitFor();
        return process.exitValue();
      } catch (InterruptedException e) {
        process.destroy();
        return null;
      }
    }
  }

  private class TestFileFilter implements FileFilter {
    @Override
    public boolean accept(File pathname) {
      if (pathname.isDirectory()) {
        return true;
      }

      String extension = getExtension(pathname.toString());
      boolean isTestFile;
      if (args.getTaskExt() != null) {
        isTestFile = args.getTaskExt().equals(extension);
      } else {
        isTestFile = !Arrays.asList(args.getInExt(), args.getExpectedOutExt(),
            args.getActualOutExt(), args.getGenerrExt(), args.getErrExt(),
            args.getCompExt()).contains(extension);
      }
      if (isTestFile) {
        boolean expectedOutExists = getDefaultOut(pathname).exists();
        return expectedOutExists || args.getGenerator() != null;
      } else {
        return false;
      }
    }
  }
}
