package ro.uaic.javasemantics.tools;

import java.util.*;

/**
 * Date: 23.05.2012
 *
 * @author denis.bogdanas@gmail.com
 */
public class RunnerArgs {

  private List<String> targetFileDirs;
  private String generator;
  private boolean conditionalGenerator;
  private String runner;
  private String taskExt;
  private int timeout;
  private int threads;
  private String reportFile;
  private String inExt;
  private String expectedOutExt;
  private String actualOutExt;
  private String errExt;
  private String generrExt;
  private String compExt;
  private String testsuiteName;
  private String removeScript;
  private boolean clean;
  private boolean smartGen;
  private final boolean classnameStyleComplete;

  public RunnerArgs(String[] args) {
    if (args.length == 0) {
      throw new IllegalArgumentException(
          "Test runner should have at least one argument.");
    }
    Map<String, String> argsMap = new LinkedHashMap<String, String>();
    argsMap.put("-gen", null);
    argsMap.put("-condGen", "true");
    argsMap.put("-run", null);
    argsMap.put("-taskExt", null);
    argsMap.put("-timeout", "0");
    argsMap.put("-threads", "1");
    argsMap.put("-rep", "test-results.xml");
    argsMap.put("-inExt", "in");
    argsMap.put("-expectedOutExt", "out");
    argsMap.put("-actualOutExt", "stdout");
    argsMap.put("-errExt", "stderr");
    argsMap.put("-generrExt", "generr");
    argsMap.put("-compExt", "comp");
    argsMap.put("-testsuiteName", "");
    argsMap.put("-classnameStyle", "complete");
    argsMap.put("-rm", null);
    argsMap.put("-clean", "true");
    argsMap.put("-smartGen", "true");
    Set<String> allOptions = new HashSet<String>(argsMap.keySet());
    int i;
    for (i = 0; i < args.length; i += 2) {
      if (args[i].charAt(0) == '-') {
        argsMap.put(args[i], args[i + 1]);
      } else {
        break;//the remaining arguments are target file/dirs.
      }
    }

    targetFileDirs = new ArrayList<String>();
    targetFileDirs.addAll(Arrays.asList(args).subList(i, args.length));
    if (targetFileDirs.isEmpty()) {
      throw new IllegalArgumentException(
          "At least one target file or dir should be specified.");
    }

    if (argsMap.get("-run") == null && argsMap.get("-gen") == null) {
      throw new IllegalArgumentException(
          "At least one of arguments -gen -run should be set. " +
              "Received arguments are: " + argsMap);
    }
    if (!allOptions.equals(argsMap.keySet())) {
      throw new IllegalArgumentException(
          "Some arguments are invalid. Received arguments are:" + argsMap);
    }

    generator = argsMap.get("-gen");
    conditionalGenerator = Boolean.parseBoolean(argsMap.get("-condGen"));
    runner = argsMap.get("-run");
    taskExt = argsMap.get("-taskExt");
    timeout = Integer.parseInt(argsMap.get("-timeout"));
    threads = Integer.parseInt(argsMap.get("-threads"));
    reportFile = argsMap.get("-rep");
    inExt = argsMap.get("-inExt");
    expectedOutExt = argsMap.get("-expectedOutExt");
    actualOutExt = argsMap.get("-actualOutExt");
    errExt = argsMap.get("-errExt");
    generrExt = argsMap.get("-generrExt");
    compExt = argsMap.get("-compExt");
    testsuiteName = argsMap.get("-testsuiteName");
    classnameStyleComplete = "complete".equals(argsMap.get("-classnameStyle"));
    removeScript = argsMap.get("-rm");
    clean = Boolean.parseBoolean(argsMap.get("-clean"));
    smartGen = Boolean.parseBoolean(argsMap.get("-smartGen"));

    if (threads <= 0) {
      throw new IllegalArgumentException("threads value should be >= 1");
    }
  }

  public List<String> getTargetFileDirs() {
    return targetFileDirs;
  }

  public String getGenerator() {
    return generator;
  }

  public boolean isConditionalGenerator() {
    return conditionalGenerator;
  }

  public String getRunner() {
    return runner;
  }

  public String getTaskExt() {
    return taskExt;
  }

  public int getTimeout() {
    return timeout;
  }

  public int getThreads() {
    return threads;
  }

  public String getReportFile() {
    return reportFile;
  }

  public String getInExt() {
    return inExt;
  }

  public String getExpectedOutExt() {
    return expectedOutExt;
  }

  public String getActualOutExt() {
    return actualOutExt;
  }

  public String getErrExt() {
    return errExt;
  }

  public String getGenerrExt() {
    return generrExt;
  }

  public String getCompExt() {
    return compExt;
  }

  public String getTestsuiteName() {
    return testsuiteName;
  }

  public boolean isClassnameStyleComplete() {
    return classnameStyleComplete;
  }

  public String getRemoveScript() {
    return removeScript;
  }

  public boolean isClean() {
    return clean;
  }

  public boolean isSmartGen() {
    return smartGen;
  }
}
