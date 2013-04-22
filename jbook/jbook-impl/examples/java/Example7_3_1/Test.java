class Author extends Thread {
    private char letter;
    private StringBuffer book;

    Author(StringBuffer b, char c) {
	book   = b;
	letter = c;
    }

    public void run() {
	synchronized (book) {
	    while (book.length() < 40) {
		book.append(letter);
		book.notify();
		try { book.wait(); }
		catch (InterruptedException e) { }
	    }
	    book.notify();
	}
    }
}

class Publisher extends Thread {
    private StringBuffer book;

    Publisher(StringBuffer b) { 
	book =  b;
    }

    public void run() {
	synchronized (book) {
	    while (book.length() < 40) {
		book.notify();
		try { book.wait(); }
		catch (InterruptedException e) { }
	    }
	    System.out.println(book);
	    book.notifyAll();
	}
    }
}

class Test {
    public static void main(String[] args) {
	StringBuffer book = new StringBuffer(40);
	int i = 0;
	while (i<10) {
	    new Author(book, (char)('A'+i)).start();
	    i = i+1;
	}
	new Publisher(book).start();
    }
}

