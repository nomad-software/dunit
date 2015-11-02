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
import dunit.error;
import dunit.moduleunittester;
import std.algorithm;
import std.array;
import std.math;
import std.regex;
import std.stdio;
import std.string;
import std.traits;
import std.range : isInputRange, walkLength;

/**
 * Assert that two floating point values are approximately equal.
 *
 * See_Also:
 *     $(LINK http://www.cygnus-software.com/papers/comparingfloats/comparingfloats.htm)
 *
 * Params:
 *     value = The value used during the assertion.
 *     target = The target value.
 *     ulps = The maximum space between two approximately equal floating point numbers measured in $(LINK2 http://en.wikipedia.org/wiki/Unit_in_the_last_place, units of least precision). A higher number means more approximation.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertApprox(A, B)(A value, B target, long ulps = 10, string message = "Failed asserting approximately equal", string file = __FILE__, size_t line = __LINE__) if (isFloatingPoint!(CommonType!(A, B)))
{
	static if (is(CommonType!(A, B) == double))
	{
		long maximumUlps       = 0x8000000000000;
		long negativeZeroFloat = 0x8000000000000000;
		long intValue          = *(cast(ulong*)&value);
		long intTarget         = *(cast(ulong*)&target);
		long difference;
	}
	else
	{
		int maximumUlps       = 0x400000;
		int negativeZeroFloat = 0x80000000;
		int intValue          = *(cast(int*)&value);
		int intTarget         = *(cast(int*)&target);
		int difference;
	}

	ulps.assertGreaterThan(0, "Unit of least precision should be above 0", file, line);
	ulps.assertLessThan(maximumUlps, format("Unit of least precision should be below %s", maximumUlps), file, line);

	if (intValue < 0)
	{
		intValue = negativeZeroFloat - intValue;
	}

	if (intTarget < 0)
	{
		intTarget = negativeZeroFloat - intTarget;
	}

	difference = abs(intValue - intTarget);

	if (difference > ulps)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedExpectation("Expected value", target);
		error.addTypedError("Actual value", value);

		throw error;
	}
}

///
unittest
{
	float smallestFloatSubnormal = float.min_normal * float.epsilon;
	smallestFloatSubnormal.assertApprox(-smallestFloatSubnormal);

	double smallestDoubleSubnormal = double.min_normal * double.epsilon;
	smallestDoubleSubnormal.assertApprox(-smallestDoubleSubnormal);

	0.0f.assertApprox(-0.0f);
	(-0.0f).assertApprox(0.0f);
	0.0.assertApprox(-0.0);
	(-0.0).assertApprox(0.0);
	2.0f.assertApprox(1.999999f);
	1.999999f.assertApprox(2.0f);
	2.0.assertApprox(1.999999999999999);
	1.999999999999999.assertApprox(2.0);

	// The following tests pass but are open for debate whether or not they should.
	float.max.assertApprox(float.infinity);
	float.infinity.assertApprox(float.max);
	double.infinity.assertApprox(double.max);
	double.max.assertApprox(double.infinity);
	float.nan.assertApprox(float.nan);
	double.nan.assertApprox(double.nan);

	// Assert a DUnitAssertError is thrown if assertApprox fails.
	10f.assertApprox(0f).assertThrow!(DUnitAssertError)("Failed asserting approximately equal");
}

/**
 * Assert that two floating point values are approximately equal using an epsilon value.
 *
 * See_Also:
 *     $(LINK http://www.cygnus-software.com/papers/comparingfloats/comparingfloats.htm)
 *
 * Params:
 *     value = The value used during the assertion.
 *     target = The target value.
 *     epsilon = An epsilon value to be used as the maximum absolute and relative error in the comparison.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertApprox(A, B)(A value, B target, double epsilon, string message = "Failed asserting approximately equal", string file = __FILE__, size_t line = __LINE__) if (isFloatingPoint!(CommonType!(A, B)))
{
	auto divisor       = (fabs(value) > fabs(target)) ? value : target;
	auto absoluteError = fabs(value - target);
	auto relativeError = fabs((value - target) / divisor);

	if (absoluteError > epsilon && relativeError > epsilon)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedExpectation("Expected value", target);
		error.addTypedError("Actual value", value);

		throw error;
	}
}

///
unittest
{
	float smallestFloatSubnormal = float.min_normal * float.epsilon;
	smallestFloatSubnormal.assertApprox(-smallestFloatSubnormal, 0.00001);

	double smallestDoubleSubnormal = double.min_normal * double.epsilon;
	smallestDoubleSubnormal.assertApprox(-smallestDoubleSubnormal, 0.00001);

	0.0f.assertApprox(-0.0f, 0.00001);
	(-0.0f).assertApprox(0.0f, 0.00001);
	0.0.assertApprox(-0.0, 0.00001);
	(-0.0).assertApprox(0.0, 0.00001);
	2.0f.assertApprox(1.99f, 0.01);
	1.99f.assertApprox(2.0f, 0.01);
	2.0.assertApprox(1.99, 0.01);
	1.99.assertApprox(2.0, 0.01);

	// The following tests pass but are open for debate whether or not they should.
	float.max.assertApprox(float.infinity, 0.00001);
	float.infinity.assertApprox(float.max, 0.00001);
	double.infinity.assertApprox(double.max, 0.00001);
	double.max.assertApprox(double.infinity, 0.00001);
	float.nan.assertApprox(float.nan, 0.00001);
	double.nan.assertApprox(double.nan, 0.00001);

	// Assert a DUnitAssertError is thrown if assertApprox fails.
	10f.assertApprox(0f, 0.00001).assertThrow!(DUnitAssertError)("Failed asserting approximately equal");
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
public void assertCount(A)(A array, ulong count, string message = "Failed asserting array count", string file = __FILE__, size_t line = __LINE__) if (isArray!(A) || isAssociativeArray!(A))
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

///
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

	// Assert a DUnitAssertError is thrown if assertCount fails.
	associativeArray.assertCount(1).assertThrow!(DUnitAssertError)("Failed asserting array count");
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
public void assertEmpty(A)(A array, string message = "Failed asserting empty array", string file = __FILE__, size_t line = __LINE__)
	if (isInputRange!(A) || isArray!(A) || isAssociativeArray!(A))
{
	if (array.length > 0)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addInfo("Elements", array);
		error.addExpectation("Expected count", 0);

		static if (isInputRange!(A))
			error.addError("Actual count", array.walkLength);
		else
			error.addError("Actual count", array.length);

		throw error;
	}
}

///
unittest
{
	int[string] associativeArray;
	int[] dynamicArray;
	string string_;

	associativeArray.assertEmpty();
	dynamicArray.assertEmpty();
	string_.assertEmpty();
	[].assertEmpty();

	// Assert a DUnitAssertError is thrown if assertEmpty fails.
	[1].assertEmpty().assertThrow!(DUnitAssertError)("Failed asserting empty array");
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
public void assertEndsWith(string value, string suffix, string message = "Failed asserting ends with", string file = __FILE__, size_t line = __LINE__)
{
	if (!endsWith(value, suffix))
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Expected end", "..." ~ suffix);
		error.addError("Actual value", value);

		throw error;
	}
}

///
unittest
{
	"foo bar".assertEndsWith("bar");
	"baz qux".assertEndsWith("qux");

	// Assert a DUnitAssertError is thrown if assertEndsWith fails.
	"foo".assertEndsWith("bar").assertThrow!(DUnitAssertError)("Failed asserting ends with");
}

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
public void assertEqual(A, B)(A value, B target, string message = "Failed asserting equal", string file = __FILE__, size_t line = __LINE__)
{
	if (target != value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedExpectation("Expected value", target);
		error.addTypedError("Actual value", value);

		throw error;
	}
}

///
unittest
{
	123.assertEqual(123);
	"hello".assertEqual("hello");

	// Assert a DUnitAssertError is thrown if assertEqual fails.
	1.assertEqual(2).assertThrow!(DUnitAssertError)("Failed asserting equal");
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
public void assertFalse(T)(T value, string message = "Failed asserting false", string file = __FILE__, size_t line = __LINE__)
{
	value.assertType!(bool)("Wrong type for asserting false", file, line);

	if (value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addError("Value", value);

		throw error;
	}
}

///
unittest
{
	false.assertFalse();

	// Assert a DUnitAssertError is thrown if assertFalse fails.
	true.assertFalse().assertThrow!(DUnitAssertError)("Failed asserting false");
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
public void assertFalsey(T)(T value, string message = "Failed asserting falsey", string file = __FILE__, size_t line = __LINE__)
{
	if (value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedInfo("Value", value);
		error.addError("Evaluates to", !!value);

		throw error;
	}
}

///
unittest
{
	false.assertFalsey();
	[].assertFalsey();
	null.assertFalsey();
	0.assertFalsey();

	// Assert a DUnitAssertError is thrown if assertFalsey fails.
	true.assertFalsey().assertThrow!(DUnitAssertError)("Failed asserting falsey");
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
public void assertGreaterThan(A, B)(A value, B threshold, string message = "Failed asserting greater than", string file = __FILE__, size_t line = __LINE__)
{
	if (value <= threshold)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Minimum value", threshold + 1);
		error.addError("Actual value", value);

		throw error;
	}
}

///
unittest
{
	11.assertGreaterThan(10);

	// Assert a DUnitAssertError is thrown if assertGreaterThan fails.
	11.assertGreaterThan(12).assertThrow!(DUnitAssertError)("Failed asserting greater than");
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
public void assertGreaterThanOrEqual(A, B)(A value, B threshold, string message = "Failed asserting greater than or equal", string file = __FILE__, size_t line = __LINE__)
{
	if (value < threshold)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Minimum value", threshold);
		error.addError("Actual value", value);

		throw error;
	}
}

///
unittest
{
	10.assertGreaterThanOrEqual(10);
	11.assertGreaterThanOrEqual(10);

	// Assert a DUnitAssertError is thrown if assertGreaterThanOrEqual fails.
	11.assertGreaterThanOrEqual(12).assertThrow!(DUnitAssertError)("Failed asserting greater than or equal");
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
public void assertHasKey(A, B)(A haystack, B needle, string message = "Failed asserting array has key", string file = __FILE__, size_t line = __LINE__) if (isAssociativeArray!(A))
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

///
unittest
{
	["foo":1, "bar":2, "baz":3, "qux":4].assertHasKey("foo");
	[1:"foo", 2:"bar", 3:"baz", 4:"qux"].assertHasKey(1);

	// Assert a DUnitAssertError is thrown if assertHasKey fails.
	["foo":"bar"].assertHasKey("baz").assertThrow!(DUnitAssertError)("Failed asserting array has key");
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
public void assertHasValue(A, B)(A haystack, B needle, string message = "Failed asserting array has value", string file = __FILE__, size_t line = __LINE__) if (isArray!(A) || isAssociativeArray!(A))
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

///
unittest
{
	"Hello".assertHasValue("H");
	[1, 2, 3, 4].assertHasValue(2);
	["foo", "bar", "baz", "qux"].assertHasValue("foo");
	[["foo", "bar"], ["baz", "qux"]].assertHasValue(["foo", "bar"]);
	["foo":1, "bar":2, "baz":3, "qux":4].assertHasValue(4);

	// Assert a DUnitAssertError is thrown if assertHasValue fails.
	["foo":"bar"].assertHasValue("baz").assertThrow!(DUnitAssertError)("Failed asserting array has value");
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
public void assertInstanceOf(A, B)(B value, string message = "Failed asserting instance of", string file = __FILE__, size_t line = __LINE__)
{
	if (!cast(A)value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Expected instance", A.stringof);
		error.addError("Non derived type", B.stringof);

		throw error;
	}
}

///
unittest
{
	interface A {}
	class B : A {}
	class C : B {}

	auto b = new B();
	auto c = new C();

	b.assertInstanceOf!(Object)();
	b.assertInstanceOf!(A)();
	b.assertInstanceOf!(B)();

	c.assertInstanceOf!(Object)();
	c.assertInstanceOf!(A)();
	c.assertInstanceOf!(B)();
	c.assertInstanceOf!(C)();

	// Assert a DUnitAssertError is thrown if assertInstanceOf fails.
	b.assertInstanceOf!(C)().assertThrow!(DUnitAssertError)("Failed asserting instance of");
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
public void assertLessThan(A, B)(A value, B threshold, string message = "Failed asserting less than", string file = __FILE__, size_t line = __LINE__)
{
	if (value >= threshold)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Maximum value", threshold - 1);
		error.addError("Actual value", value);

		throw error;
	}
}

///
unittest
{
	9.assertLessThan(10);

	// Assert a DUnitAssertError is thrown if assertLessThan fails.
	9.assertLessThan(8).assertThrow!(DUnitAssertError)("Failed asserting less than");
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
public void assertLessThanOrEqual(A, B)(A value, B threshold, string message = "Failed asserting less than or equal", string file = __FILE__, size_t line = __LINE__)
{
	if (value > threshold)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Maximum value", threshold);
		error.addError("Actual value", value);

		throw error;
	}
}

///
unittest
{
	10.assertLessThanOrEqual(10);
	9.assertLessThanOrEqual(10);

	// Assert a DUnitAssertError is thrown if assertLessThanOrEqual fails.
	9.assertLessThanOrEqual(8).assertThrow!(DUnitAssertError)("Failed asserting less than or equal");
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
public void assertMatchRegex(string value, string pattern, string message = "Failed asserting match to regex", string file = __FILE__, size_t line = __LINE__)
{
	if (match(value, pattern).empty())
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addInfo("Regex", pattern);
		error.addError("Value", value);

		throw error;
	}
}

///
unittest
{
	"foo".assertMatchRegex(r"^foo$");
	"192.168.0.1".assertMatchRegex(r"((?:[\d]{1,3}\.){3}[\d]{1,3})");

	// Assert a DUnitAssertError is thrown if assertMatchRegex fails.
	"foo".assertMatchRegex(r"^bar$").assertThrow!(DUnitAssertError)("Failed asserting match to regex");
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
public void assertNull(A)(A value, string message = "Failed asserting null", string file = __FILE__, size_t line = __LINE__) if (A.init is null)
{
	if (value !is null)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedError("Actual value", value);

		throw error;

	}
}

///
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

	// Assert a DUnitAssertError is thrown if assertNull fails.
	"foo".assertNull().assertThrow!(DUnitAssertError)("Failed asserting null");
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
public void assertStartsWith(string value, string prefix, string message = "Failed asserting starts with", string file = __FILE__, size_t line = __LINE__)
{
	if (!startsWith(value, prefix))
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Expected start", prefix ~ "...");
		error.addError("Actual value", value);

		throw error;
	}
}

///
unittest
{
	"foo bar".assertStartsWith("foo");
	"baz qux".assertStartsWith("baz");

	// Assert a DUnitAssertError is thrown if assertStartsWith fails.
	"foo bar".assertStartsWith("baz").assertThrow!(DUnitAssertError)("Failed asserting starts with");
}

/**
 * Assert that an expression throws an exception.
 *
 * Params:
 *     expression = The expression to evaluate in order to assert the exception is thrown.
 *     expressionMsg = An optional expected message of the thrown exception.
 *     message = The error message to display.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 *
 * Throws:
 *     DUnitAssertError if the assertation fails.
 */
public void assertThrow(A : Throwable = Exception, B)(lazy B expression, string expressionMsg = null, string message = "Failed asserting throw", string file = __FILE__, size_t line = __LINE__)
{
	try
	{
		try
		{
			expression;
		}
		catch (A ex)
		{
			if (expressionMsg !is null && expressionMsg != ex.msg)
			{
				auto error = new DUnitAssertError(message, file, line);

				error.addExpectation("Expected message", expressionMsg);
				error.addError("Thrown message", ex.msg);

				throw error;
			}
			return;
		}
	}
	catch (Exception ex)
	{
		// If the expression throws an exception other than the one specified just let it pass.
		// We can't get any meaningful information about what was thrown anyway.
	}

	auto error = new DUnitAssertError(message, file, line);

	error.addError("Expected exception", A.stringof);

	throw error;
}

///
unittest
{
	import core.exception : AssertError, RangeError;

	class Foo : Exception
	{
		this(string message)
		{
			super(message);
		}
	}

	class Bar
	{
		public void baz()
		{
			throw new Foo("Thrown from baz.");
		}
	}

	auto bar = new Bar();
	bar.baz().assertThrow();
	bar.baz().assertThrow!(Foo)("Thrown from baz.");

	delegate(){throw new Foo("Thrown from delegate.");}().assertThrow!(Exception)("Thrown from delegate.");

	auto baz = [0, 1, 2];
	baz[3].assertThrow!(RangeError)();

	assert(false).assertThrow!(AssertError)("Assertion failure");

	// Assert a DUnitAssertError is thrown if assertThrow fails.
	null.assertThrow().assertThrow!(DUnitAssertError)("Failed asserting throw");

	// Assert a DUnitAssertError is thrown if assertThrow fails due to mismatched error message.
	baz[3].assertThrow!(RangeError)("Foo").assertThrow!(DUnitAssertError)("Failed asserting throw");
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
public void assertTrue(T)(T value, string message = "Failed asserting true", string file = __FILE__, size_t line = __LINE__)
{
	value.assertType!(bool)("Wrong type for asserting true", file, line);

	if (!value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addError("Value", value);

		throw error;
	}
}

///
unittest
{
	true.assertTrue();

	// Assert a DUnitAssertError is thrown if assertTrue fails.
	false.assertTrue().assertThrow!(DUnitAssertError)("Failed asserting true");
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
public void assertTruthy(T)(T value, string message = "Failed asserting truthy", string file = __FILE__, size_t line = __LINE__)
{
	if (!value)
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addTypedInfo("Value", value);
		error.addError("Evaluates to", !!value);

		throw error;
	}
}

///
unittest
{
	true.assertTruthy();
	["foo"].assertTruthy();
	1.assertTruthy();

	// Assert a DUnitAssertError is thrown if assertTruthy fails.
	false.assertTruthy().assertThrow!(DUnitAssertError)("Failed asserting truthy");
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
public void assertType(A, B)(B value, string message = "Failed asserting type", string file = __FILE__, size_t line = __LINE__)
{
	if (!is(A == B))
	{
		auto error = new DUnitAssertError(message, file, line);

		error.addExpectation("Expected type", A.stringof);
		error.addError("Actual type", B.stringof);

		throw error;
	}
}

///
unittest
{
	1.assertType!(int)();
	"foo".assertType!(string)();
	["bar"].assertType!(string[])();
	['a'].assertType!(char[])();

	// Assert a DUnitAssertError is thrown if assertType fails.
	false.assertType!(string)().assertThrow!(DUnitAssertError)("Failed asserting type");
}
