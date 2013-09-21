import dunit.mockable;
import std.algorithm;

/**
 * Simple class representing a person.
 */
class Person
{
	private string _name;
	private int _age;

	this()
	{
	}

	this(string name, int age)
	{
		this._name = name;
		this._age  = age;
	}

	public string getName()
	{
		return this._name;
	}

	public int getAge()
	{
		return this._age;
	}
	
	// Mixin mocking behaviour.
	mixin Mockable!(Person);
}

/**
 * Processor class that uses Person as a dependency.
 */
class Processor
{
	private Person[] _people;

	public void addPerson(Person person)
	{
		this._people ~= person;
	}

	public ulong getAmountOfPeople()
	{
		return this._people.length;
	}

	public float getMeanAge()
	{
		return cast(float)reduce!((a, b) => a + b.getAge())(0, this._people) / this.getAmountOfPeople();
	}
}

unittest
{
	import dunit.toolkit;

	// Create mock people.
	auto gary  = Person.getMock();
	auto tessa = Person.getMock();

	// Mock the getAge method to return 40. Set the minimum count to 1 and the maximum count to 1.
	gary.mockMethod("getAge", delegate(){
		return 40;
	}, 1, 1);

	// Mock the getAge method to return 34. Set the minimum count to 1 and the maximum count to 1.
	tessa.mockMethod("getAge", delegate(){
		return 34;
	}, 1, 1);

	// Create the object we are unit testing.
	auto processor = new Processor();

	// Add mock people to the processor.
	processor.addPerson(gary);
	processor.addPerson(tessa);

	// Make assertions of the processor, calling the mock methods on the mock class.
	processor.getAmountOfPeople().assertEqual(2);
	processor.getMeanAge().assertEqual(37);

	// Assert mock method calls are within limits.
	gary.assertMethodCalls();
	tessa.assertMethodCalls();
}
