package ro.uaic.javasemantics.tools;

import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.commons.lang3.text.translate.CharSequenceTranslator;
import org.apache.commons.lang3.text.translate.LookupTranslator;

import java.io.FileWriter;
import java.io.IOException;
import java.util.Formatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Future;

/**
 * Date: 26.05.2012
 *
 * @author denis.bogdanas@gmail.com
 */
public class XmlBuilder {
  private RunnerArgs args;
  private List<Future<TestResult>> results;
  private long startTime;
  private Map<String, Integer> statusCountMap = new HashMap<String, Integer>();

  private Formatter out = new Formatter(System.out);

  public XmlBuilder(RunnerArgs args, List<Future<TestResult>> results, long startTime) {
    this.args = args;
    this.results = results;
    this.startTime = startTime;
  }

  @SuppressWarnings("StringConcatenationInsideStringBufferAppend")
  public void buildXml() {
    StringBuilder xml = new StringBuilder();
    CharSequenceTranslator translator =
        StringEscapeUtils.ESCAPE_XML.with(new LookupTranslator(new CharSequence[][]{{"\0", ""}}));
    TestResult previousResult = null, result;
    try {
      for (int i = 0, resultsSize = results.size(); i < resultsSize; i++) {
        try {
          result = results.get(i).get();
        } catch (InterruptedException ie) {
          System.out.println("interrupted...  ");
          xml.append("<interrupted/>\n\n");
          break;
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
        results.set(i, null);
        writeConsoleMessage(result, previousResult);

        xml.append("<testcase")
            .append(" classname='").append(result.getDirName(args.isClassnameStyleComplete()))
            .append("'")
            .append(" name='").append(result.getFileName()).append("'")
            .append(" time='").append(result.getTime() / 1000.0).append("'")
            .append(">\n");

        if (result.containsError()) {
          String errorMsg
              = args.isEncodeXML() ? translator.translate(result.getError()) : result.getError();
          xml.append("<error>\n")
              .append(errorMsg)
              .append("</error>\n");
        }
        if (result.getComp() != null) {
          String failureMsg
              = args.isEncodeXML() ? translator.translate(result.getComp()) : result.getComp();
          xml.append("<failure>\n")
              .append(failureMsg)
              .append("</failure>\n");
        }

        xml.append("</testcase>\n\n");

        previousResult = result;
      }
      StringBuilder xmlStart = new StringBuilder();
      xmlStart
          .append("<?xml version='1.0' encoding='UTF-8' ?>\n")
          .append("<testsuite")
          .append(" name='").append(args.getTestsuiteName()).append("'")
          .append(" tests='").append(getNrTests()).append("'")
          .append(" errors='").append(getNrErrorResults()).append("'")
          .append(" failures='").append(statusCountMap.get("failed")).append("'")
          .append(" time='").append(getTotalTime()).append("'")
          .append(">\n\n");
      xml.insert(0, xmlStart);
      xml.append("</testsuite>\n");

    } finally {
      try {
        FileWriter xmlFile = new FileWriter(args.getReportFile());
        xmlFile.append(xml);
        xmlFile.close();
      } catch (IOException e) {
        e.printStackTrace();
      }
      printSummary();
    }
  }

  private int getNrTests() {
    int nrTests = 0;
    for (Integer val : statusCountMap.values()) {
      nrTests += val;
    }
    return nrTests;
  }

  private int getNrErrorResults() {
    int nrTests = 0;
    for (Map.Entry<String, Integer> entry : statusCountMap.entrySet()) {
      if (!(entry.getKey().equals("ok") || entry.getKey().equals("failed"))) {
        nrTests += entry.getValue();
      }
    }
    return nrTests;
  }

  private void printSummary() {
    System.out.println();
    for (String status : statusCountMap.keySet()) {
      int count = statusCountMap.get(status);
      if (count > 0) {
        out.format("%-6s:  %d\n", status, count);
      }
    }
    out.format("%-6s:  %d\n", "total", getNrTests());
  }

  private void writeConsoleMessage(TestResult result, TestResult previousResult) {
    String status = result.getStatus();
    if (!statusCountMap.containsKey(status)) {
      statusCountMap.put(status, 0);
    }
    statusCountMap.put(status, statusCountMap.get(status) + 1);
    if (previousResult == null
        || !previousResult.getDirName(true).equals(result.getDirName(true))) {
      if (previousResult != null) {
        System.out.println();
      }
      System.out.println(result.getDirName(true) + ":");
    }
    System.out.println("    " + result.getFileName() + "...  " + status);
  }

  public String getTotalTime() {
    return String.format("%.3f", (System.currentTimeMillis() - startTime) / 1000.0);
  }
}
