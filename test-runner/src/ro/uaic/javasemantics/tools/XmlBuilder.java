package ro.uaic.javasemantics.tools;

import java.io.FileWriter;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.Future;

/**
 * Date: 26.05.2012
 *
 * @author denis.bogdanas@gmail.com
 */
public class XmlBuilder {
  private RunnerArgs args;
  private List<Future<TestResult>> results;
  int nrOk, nrFailure, nrError;

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
    if (nrOk > 0) {
      System.out.println("passed:  " + nrOk);
    }
    if (nrFailure > 0) {
      System.out.println("failed:  " + nrFailure);
    }
    if (nrError > 0) {
      System.out.println("error :  " + nrError);
    }
    System.out.println("total :  " + (nrOk + nrFailure + nrError));
  }

  private void writeConsoleMessage(TestResult result) {
    String status;
    if (result.containsError()) {
      status = "error";
      nrError++;
    } else if (result.isSuccess()) {
      status = "ok";
      nrOk++;
    } else {
      status = "failed";
      nrFailure++;
    }
    System.out.println(result.getName() + "...  " + status);
  }
}
