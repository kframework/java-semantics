package java.lang;

public class RuntimeException {
    private String detailMessage;
    private RuntimeException cause;

    public RuntimeException() {}

    public RuntimeException(String message) {
        detailMessage = message;
    }

    public RuntimeException(RuntimeException cause) {
        detailMessage = (cause==null ? null : cause.toString());
        this.cause = cause;
    }

    public RuntimeException(String message, RuntimeException cause) {
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
