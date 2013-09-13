// Queue.java
// Circular-array implementation

import java.io.*;

public class Misc_Queue {

	static final int MAX_QUEUE = 10;
	int front;
	int rear;
	Object [] data;

	public Misc_Queue()
	{
		front = 0;
		rear = 0;
		data = new Object[MAX_QUEUE];
	}

	static int
	next(int x)		/* Private function */
	{
		return (x + 1) % MAX_QUEUE;
	}

	boolean queueIsEmpty()
	{
		return (rear == front);
	}

	boolean queueIsFull()
	{
		return (next(rear) == front);
	}

	boolean QueueAdd(Object NewItem)
	{
		if (queueIsFull())
			return false;
		else {
			data[rear] = NewItem;
			rear = next(rear);
			return true;
		}
	}

	public Object QueueRemove()
	{
		if (queueIsEmpty())
			return null;
		else
		{
			Object retval = data[front];
			front = next(front);
			return retval;
		}
	}

	public Object GetQueueFront()
	{
		if (queueIsEmpty())
			return null;
		else
			return data[front];
	}

	public void DisplayQueue()
	{
		if (queueIsEmpty())
			System.out.println("Empty Queue\n");
		else
		{
			System.out.println("\nQueue\n-----");
                        for (int i=front;i!=rear;i=next(i)) {
                          System.out.println(data[i]);
                        }
			System.out.println(" ");
		}
	}

	public static void main(String args[])
	{
		System.out.println("Start Queue\n-----------\n");
		Misc_Queue example = new Misc_Queue();

    //String str = new String("one");
    //Leads to the same result as the statement above.
    //Statement above was probably required due to some JBook-java limitation.
		String one = "one";
		System.out.print("Add: ");
		if (example.QueueAdd(one))
			System.out.println(one);
		else
			System.out.println("Insert Failed");
		example.DisplayQueue();

		String two = "two";
		System.out.print("Add: ");
		if (example.QueueAdd(two))
			System.out.println(two);
		else
			System.out.println("Insert Failed");
		example.DisplayQueue();

		System.out.print("Remove: ");
		Object result = example.QueueRemove();
		if (result == null)
			System.out.println("Failed");
		else
			System.out.println(result);
		example.DisplayQueue();

		System.out.print("Remove: ");
		result = example.QueueRemove();
		if (result == null)
			System.out.println("Failed");
		else
			System.out.println(result);
		example.DisplayQueue();

		System.out.print("Remove: ");
		result = example.QueueRemove();
		if (result == null)
			System.out.println("Failed");
		else
			System.out.println(result);
		example.DisplayQueue();

    for (int i=0;i<20;i++)
    {
      String str = "loop";
      System.out.print("Add: ");
      if (example.QueueAdd(str))
        System.out.println(str);
      else
        System.out.println("Insert Failed");
    }
		example.DisplayQueue();

                for (int i=0;i<20;i++)
		{
			System.out.print("Remove: ");
			result = example.QueueRemove();
			if (result == null)
				System.out.println("Failed");
			else
				System.out.println(result);
                }
		example.DisplayQueue();
	}
}

//Start Queue
//-----------
//
//Add: one
//
//Queue
//-----
//one
//
//Add: two
//
//Queue
//-----
//one
//two
//
//Remove: one
//
//Queue
//-----
//two
//
//Remove: two
//Empty Queue
//
//Remove: Failed
//Empty Queue
//
//Add: loop
//Add: loop
//Add: loop
//Add: loop
//Add: loop
//Add: loop
//Add: loop
//Add: loop
//Add: loop
//Add: Insert Failed
//Add: Insert Failed
//Add: Insert Failed
//Add: Insert Failed
//Add: Insert Failed
//Add: Insert Failed
//Add: Insert Failed
//Add: Insert Failed
//Add: Insert Failed
//Add: Insert Failed
//Add: Insert Failed
//
//Queue
//-----
//loop
//loop
//loop
//loop
//loop
//loop
//loop
//loop
//loop
//
//Remove: loop
//Remove: loop
//Remove: loop
//Remove: loop
//Remove: loop
//Remove: loop
//Remove: loop
//Remove: loop
//Remove: loop
//Remove: Failed
//Remove: Failed
//Remove: Failed
//Remove: Failed
//Remove: Failed
//Remove: Failed
//Remove: Failed
//Remove: Failed
//Remove: Failed
//Remove: Failed
//Remove: Failed
//Empty Queue
