public class StringBuffer {
    private String s;

    StringBuffer() {
      s = "";
    }

    StringBuffer(int length) {
      s = "";
    }

    StringBuffer(String str) {
      s = str;
    }

    StringBuffer append(char c) {
      s = s + c;
      return this;
    }

    StringBuffer append(String x) {
        s = s + x;
        return this;
    }

    int length() {
      return s.length();
    }

    public String toString() {
      return s;
    }
}
