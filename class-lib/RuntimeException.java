package java.lang;

public class RuntimeException extends Exception {

    public RuntimeException() {
        super();
    }

    public RuntimeException(String message) {
        super(message);
    }

    public RuntimeException(RuntimeException cause) {
        super(cause);
    }

    public RuntimeException(String message, RuntimeException cause) {
        super(message, cause);
    }

    public String getMessage() {
        return detailMessage;
    }
}
