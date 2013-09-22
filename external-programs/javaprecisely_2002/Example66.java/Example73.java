// Example 73 from page 55 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class WeekdayException extends Exception {
  public WeekdayException(String wday) { 
    super("Illegal weekday: " + wday); 
  }
}

