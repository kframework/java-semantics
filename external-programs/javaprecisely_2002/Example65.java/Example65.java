// Example 65 from page 49 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Example65 {
  public static void main(String[] args) {
    try {
      System.out.println(args[0] + " is weekday number " + wdayno4(args[0]));
    } catch (WeekdayException x) {
      System.out.println("Weekday problem: " + x);
    } catch (Exception x) {
      System.out.println("Other problem: " + x);
    }
  }

  // Behaves the same as wdayno3 above, but throws Exception instead of 
  // returning bogus weekday number:
  static int wdayno4(String wday) throws WeekdayException {
    for (int i=0; i < wdays.length; i++)
      if (wday.equals(wdays[i]))
        return i+1;
    throw new WeekdayException(wday);
  }

  static final String[] wdays = 
  { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };
}

