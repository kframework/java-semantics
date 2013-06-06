package java.lang;

public class Object {
    public boolean equals(Object obj) {
        return (this == obj);
    }

    public String toString() {
        return getClass().getName() + "@" + hashCode();
    }

    public final native Class getClass();

    public native int hashCode();
}
