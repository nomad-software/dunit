/**
 * Assert toolkit for more expressive unit testing.
 *
 * Many methods implement compile-time parameters (file, line) that are set at the call site.
 * It is preferred that these parameters are ignored when using these methods.
 *
 * License:
 *     MIT. See LICENSE for full details.
 */
module dunit.toolkit;

/**
 * Imports.
 */
import dunit.result;
import dunit.error;
import std.algorithm;
import std.array;
import std.regex;
import std.stdio;
import std.string;
import std.traits;

/**
 * Assert that two values are equal.
 *
 * Params:
 *     value = The value used during the assertion.
 *     target = The target value.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertEqual(A, B)(A value, B target, string message = "Failed asserting equal", string file = __FILE__, ulong line = __LINE__)
{
	if (target != value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedExpectation("Expected value", target);
		error.addTypedError("Actual value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	123.assertEqual(123);
	"hello".assertEqual("hello");
}

/**
 * Assert that an associative array contains a particular key.
 *
 * Params:
 *     haystack = The associative array to interogate.
 *     needle = The key the array should contain.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertHasKey(A, B)(A haystack, B needle, string message = "Failed asserting array has key", string file = __FILE__, ulong line = __LINE__) if (isAssociativeArray!(A))
{
	if (needle !in haystack)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addInfo("Array type", typeof(haystack).stringof);
		error.addInfo("Elements", haystack);
		error.addTypedError("Missing key", needle);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	["foo":1, "bar":2, "baz":3, "qux":4].assertHasKey("foo");
	[1:"foo", 2:"bar", 3:"baz", 4:"qux"].assertHasKey(1);
}

/**
 * Assert that an array contains a particular value.
 *
 * Params:
 *     haystack = The array to interogate.
 *     needle = The value the array should contain.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertHasValue(A, B)(A haystack, B needle, string message = "Failed asserting array has value", string file = __FILE__, ulong line = __LINE__) if (isArray!(A) || isAssociativeArray!(A))
{
	static if (isArray!(A))
	{
		bool foundValue = canFind(haystack, needle);
	}
	else static if (isAssociativeArray!(A))
	{
		bool foundValue = canFind(haystack.values, needle);
	}

	if (!foundValue)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addInfo("Array type", typeof(haystack).stringof);
		error.addInfo("Elements", haystack);
		error.addTypedError("Missing value", needle);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	"Hello".assertHasValue("H");
	[1, 2, 3, 4].assertHasValue(2);
	["foo", "bar", "baz", "qux"].assertHasValue("foo");
	[["foo", "bar"], ["baz", "qux"]].assertHasValue(["foo", "bar"]);
	["foo":1, "bar":2, "baz":3, "qux":4].assertHasValue(4);
}

/**
 * Assert that an array contains a particular value count.
 *
 * Params:
 *     array = The array to interogate.
 *     count = The amount of values the array should hold.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertCount(A)(A array, ulong count, string message = "Failed asserting array count", string file = __FILE__, ulong line = __LINE__) if (isArray!(A) || isAssociativeArray!(A))
{
	if (array.length != count)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addInfo("Elements", array);
		error.addExpectation("Expected count", count);
		error.addError("Actual count", array.length);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	int[string] associativeArray;
	int[] dynamicArray;
	string string_;

	associativeArray.assertCount(0);
	dynamicArray.assertCount(0);
	string_.assertCount(0);
	[].assertCount(0);

	"Hello".assertCount(5);
	[1, 2, 3, 4].assertCount(4);
	["foo", "bar", "baz", "qux"].assertCount(4);
	[["foo", "bar"], ["baz", "qux"]].assertCount(2);
	["foo":1, "bar":2, "baz":3, "qux":4].assertCount(4);
}

/**
 * Assert that an array is empty.
 *
 * Params:
 *     array = The array to interogate.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertEmpty(A)(A array, string message = "Failed asserting empty array", string file = __FILE__, ulong line = __LINE__) if (isArray!(A) || isAssociativeArray!(A))
{
	if (array.length > 0)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addInfo("Elements", array);
		error.addExpectation("Expected count", 0);
		error.addError("Actual count", array.length);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	int[string] associativeArray;
	int[] dynamicArray;
	string string_;

	associativeArray.assertEmpty();
	dynamicArray.assertEmpty();
	string_.assertEmpty();
	[].assertEmpty();
}

/**
 * Assert that a boolean value is false.
 *
 * Params:
 *     value = The value used during the assertion.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertFalse(T)(T value, string message = "Failed asserting false", string file = __FILE__, ulong line = __LINE__)
{
	value.assertType!(bool)("Wrong type for asserting false", file, line);

	if (value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addError("Value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	false.assertFalse();
}

/**
 * Assert that a value evaluates as false.
 *
 * Params:
 *     value = The value used during the assertion.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertFalsey(T)(T value, string message = "Failed asserting falsey", string file = __FILE__, ulong line = __LINE__)
{
	if (value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedInfo("Value", value);
		error.addError("Evaluates to", !!value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	false.assertFalsey();
	[].assertFalsey();
	null.assertFalsey();
	0.assertFalsey();
}

/**
 * Assert that a boolean value is true.
 *
 * Params:
 *     value = The value used during the assertion.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertTrue(T)(T value, string message = "Failed asserting false", string file = __FILE__, ulong line = __LINE__)
{
	value.assertType!(bool)("Wrong type for asserting true", file, line);

	if (!value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addError("Value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	true.assertTrue();
}

/**
 * Assert that a value evaluates as true.
 *
 * Params:
 *     value = The value used during the assertion.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertTruthy(T)(T value, string message = "Failed asserting true", string file = __FILE__, ulong line = __LINE__)
{
	if (!value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedInfo("Value", value);
		error.addError("Evaluates to", !!value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	true.assertTruthy();
	["foo"].assertTruthy();
	1.assertTruthy();
}

/**
 * Assert that a value is of a particular type.
 *
 * Params:
 *     value = The value used during the assertion.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertType(A, B)(B value, string message = "Failed asserting type", string file = __FILE__, ulong line = __LINE__)
{
	if (!is(A == B))
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Expected type", A.stringof);
		error.addError("Actual type", B.stringof);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	1.assertType!(int);
	"foo".assertType!(string);
	["bar"].assertType!(string[]);
	['a'].assertType!(char[]);
}

/**
 * Assert that a value is an instance of a type.
 *
 * Params:
 *     value = The value used during the assertion.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertInstanceOf(A, B)(B value, string message = "Failed asserting instance of", string file = __FILE__, ulong line = __LINE__)
{
	if (!cast(A)value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Expected instance", A.stringof);
		error.addError("Non derived type", B.stringof);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	interface A {}
	class B : A {}
	class C : B {}

	auto b = new B();
	auto c = new C();

	b.assertInstanceOf!(Object);
	b.assertInstanceOf!(A);
	b.assertInstanceOf!(B);

	c.assertInstanceOf!(Object);
	c.assertInstanceOf!(A);
	c.assertInstanceOf!(B);
	c.assertInstanceOf!(C);
}

/**
 * Assert that a value is greater than a threshold value.
 *
 * Params:
 *     value = The value used during the assertion.
 *     threshold = The threshold value.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertGreaterThan(A, B)(A value, B threshold, string message = "Failed asserting greater than", string file = __FILE__, ulong line = __LINE__)
{
	if (value <= threshold)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Minimum value", threshold + 1);
		error.addError("Actual value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	11.assertGreaterThan(10);
}

/**
 * Assert that a value is greater than or equal to a threshold value.
 *
 * Params:
 *     value = The value used during the assertion.
 *     threshold = The threshold value.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertGreaterThanOrEqual(A, B)(A value, B threshold, string message = "Failed asserting greater than or equal", string file = __FILE__, ulong line = __LINE__)
{
	if (value < threshold)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Minimum value", threshold);
		error.addError("Actual value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	10.assertGreaterThanOrEqual(10);
	11.assertGreaterThanOrEqual(10);
}

/**
 * Assert that a value is less than a threshold value.
 *
 * Params:
 *     value = The value used during the assertion.
 *     threshold = The threshold value.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertLessThan(A, B)(A value, B threshold, string message = "Failed asserting less than", string file = __FILE__, ulong line = __LINE__)
{
	if (value >= threshold)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Maximum value", threshold - 1);
		error.addError("Actual value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	9.assertLessThan(10);
}

/**
 * Assert that a value is less than or equal to a threshold value.
 *
 * Params:
 *     value = The value used during the assertion.
 *     threshold = The threshold value.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertLessThanOrEqual(A, B)(A value, B threshold, string message = "Failed asserting less than or equal", string file = __FILE__, ulong line = __LINE__)
{
	if (value > threshold)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Maximum value", threshold);
		error.addError("Actual value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	10.assertLessThanOrEqual(10);
	9.assertLessThanOrEqual(10);
}

/**
 * Assert that a value is null.
 *
 * Params:
 *     value = The value to assert as null.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertNull(A)(A value, string message = "Failed asserting null", string file = __FILE__, ulong line = __LINE__) if (A.init is null)
{
	if (value !is null)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedError("Actual value", value);

		throw error;

	}
}

/**
 * A simple example.
 */
unittest
{
	class T {}

	string foo;
	int[] bar;
	T t;

	foo.assertNull();
	bar.assertNull();
	t.assertNull();
	null.assertNull();
}

/**
 * Assert that a string matches a regular expression.
 *
 * Params:
 *     value = The value used during the assertion.
 *     pattern = The regular expression pattern.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertMatchRegex(string value, string pattern, string message = "Failed asserting match to regex", string file = __FILE__, ulong line = __LINE__)
{
	if (match(value, pattern).empty())
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addInfo("Regex", pattern);
		error.addError("Value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	"foo".assertMatchRegex(r"^foo$");
	"192.168.0.1".assertMatchRegex(r"((?:[\d]{1,3}\.){3}[\d]{1,3})");
}

/**
 * Assert that a string starts with a particular string.
 *
 * Params:
 *     value = The value used during the assertion.
 *     prefix = The prefix to match.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertStartsWith(string value, string prefix, string message = "Failed asserting starts with", string file = __FILE__, ulong line = __LINE__)
{
	if (!startsWith(value, prefix))
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Expected start", prefix ~ "...");
		error.addError("Actual value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	"foo bar".assertStartsWith("foo");
	"baz qux".assertStartsWith("baz");
}

/**
 * Assert that a string ends with a particular string.
 *
 * Params:
 *     value = The value used during the assertion.
 *     suffix = The suffix to match.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertEndsWith(string value, string suffix, string message = "Failed asserting ends with", string file = __FILE__, ulong line = __LINE__)
{
	if (!endsWith(value, suffix))
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Expected end", "..." ~ suffix);
		error.addError("Actual value", value);

		throw error;
	}
}

/**
 * A simple example.
 */
unittest
{
	"foo bar".assertEndsWith("bar");
	"baz qux".assertEndsWith("qux");
}
