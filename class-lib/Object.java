package java.lang;

class Object {
    public boolean equals(Object obj) {
        return (this == obj);
    }

    public String toString() {
        return getClass().getName() + "@" + hashCode();
    }
}
