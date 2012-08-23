package java.lang;

class RuntimeException {
    private String detailMessage = null;

    public RuntimeException(String message) {
        detailMessage = message;
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
