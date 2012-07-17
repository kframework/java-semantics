class RuntimeException {
    String detailMessage = null;

    RuntimeException(String message) {
        detailMessage = message;
    }

    String getMessage() {
        return detailMessage;
    }

    String toString() {
        String s = getClass().getName();
        String message = getMessage();
        return (message != null) ? (s + ": " + message) : s;
    }
}
