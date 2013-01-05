package ro.uaic.javasemantics.tools;

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
  private Map<String, Integer> statusCountMap = new HashMap<String, Integer>();

  {
    statusCountMap.put("ok", 0);
    statusCountMap.put("failed", 0);
    statusCountMap.put("error", 0);
  }

  private Formatter out = new Formatter(System.out);

  public XmlBuilder(RunnerArgs args, List<Future<TestResult>> results) {
    this.args = args;
    this.results = results;
  }

  @SuppressWarnings("StringConcatenationInsideStringBufferAppend")
  public void buildXml() {
    try {
      FileWriter xml = new FileWriter(args.getReportFile());
      xml.append("<?xml version='1.0' encoding='UTF-8' ?>\n");
      xml.append("<testsuite name='" + args.getTestsuiteName() + "'>\n\n");
      for (int i = 0, resultsSize = results.size(); i < resultsSize; i++) {
        TestResult result;
        try {
          result = results.get(i).get();
        } catch (InterruptedException ie) {
          System.out.println("interrupted...  ");
          xml.append("</interrupted>\n\n");
          break;
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
        results.set(i, null);
        writeConsoleMessage(result);

        xml.append("<testcase name='" + result.getName() + "' time='" +
            result.getTime() / 1000.0 + "'>\n");

        if (result.containsError()) {
          xml.append("<error>\n");
          xml.append(result.getError());
          xml.append("</error>\n");
        }
        if (result.getComp() != null) {
          xml.append("<failure>\n");
          xml.append(result.getComp());
          xml.append("</failure>\n");
        }

        xml.append("</testcase>\n\n");
      }
      xml.append("</testsuite>\n");
      xml.close();

    } catch (IOException e) {
      throw new RuntimeException(e);
    } finally {
      printSummary();
    }
  }

  private void printSummary() {
    System.out.println();
    int total = 0;
    for (String status : statusCountMap.keySet()) {
      int count = statusCountMap.get(status);
      if (count > 0) {
        out.format("%-6s:  %d\n", status, count);
        total += count;
      }
    }
    out.format("%-6s:  %d\n", "total", total);
  }

  private void writeConsoleMessage(TestResult result) {
    String highLevelStatus = result.getHighLevelStatus();
    String status = result.getStatus();
    statusCountMap.put(highLevelStatus, statusCountMap.get(highLevelStatus) + 1);
    System.out.println(result.getName() + "...  " + status);
  }
}
