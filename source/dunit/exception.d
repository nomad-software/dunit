/**
 * Module to handle exceptions.
 *
 * License:
 *     MIT. See LICENSE.txt for full details.
 */
module dunit.exception;

/**
 * Imports.
 */
import core.exception;
import std.string;

/**
 * An exception thrown when a unit test fails.
 */
class DUnitAssertError : AssertError
{
	/**
	 * Values to display in the message.
	 */
	private string[] _log;

	/**
	 * Constructor.
	 */
	this(string message, string file, size_t line)
	{
		super(message, file, line);
	}

	/**
	 * Return the exception log.
	 */
	public @property string[] log()
	{
		return this._log;
	}

	/**
	 * Add a line of info to the exception log.
	 */
	public void addInfo(T)(string caption, T value, string prefix = "ℹ")
	{
		this._log ~= format("%s %s: %s", prefix, caption, value);
	}

	/**
	 * Add a line of typed info to the exception log.
	 */
	public void addTypedInfo(T)(string caption, T value, string prefix = "ℹ")
	{
		this._log ~= format("%s %s: (%s) %s", prefix, caption, T.stringof, value);
	}

	/**
	 * Add a line of expected info to the exception log.
	 */
	public void addExpectation(T)(string caption, T value, string prefix = "✓")
	{
		this.addInfo!(T)(caption, value, prefix);
	}

	/**
	 * Add a line of typed expected info to the exception log.
	 */
	public void addTypedExpectation(T)(string caption, T value, string prefix = "✓")
	{
		this.addTypedInfo!(T)(caption, value, prefix);
	}

	/**
	 * Add a line of error info to the exception log.
	 */
	public void addError(T)(string caption, T value, string prefix = "✗")
	{
		this.addInfo!(T)(caption, value, prefix);
	}

	/**
	 * Add a line of typed error info to the exception log.
	 */
	public void addTypedError(T)(string caption, T value, string prefix = "✗")
	{
		this.addTypedInfo!(T)(caption, value, prefix);
	}
}
