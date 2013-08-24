package java.lang;

public class Exception {
    private String detailMessage;
    private Exception cause;

    public Exception() {}

    public Exception(String message) {
        detailMessage = message;
    }

    public Exception(Exception cause) {
        detailMessage = (cause==null ? null : cause.toString());
        this.cause = cause;
    }

    public Exception(String message, Exception cause) {
        detailMessage = message;
        this.cause = cause;
    }

    public String getMessage() {
        return detailMessage;
    }

    public String toString() {
        String s = getClass().getName();
        String message = getMessage();
        return (message != null) ? (s + ": " + message) : s;
    }
}
