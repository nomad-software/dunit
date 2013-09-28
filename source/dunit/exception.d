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
	private string[] _info;

	/**
	 * Constructor.
	 */
	this(string message, string file, size_t line)
	{
		super(message, file, line);
	}

	/**
	 * Add a line of info to the exception.
	 */
	public void addInfo(T)(string caption, T value, string prefix = "ℹ")
	{
		this._info ~= format("%s %s: %s", prefix, caption, value);
	}

	/**
	 * Add a line of typed info to the exception.
	 */
	public void addTypedInfo(T)(string caption, T value, string prefix = "ℹ")
	{
		this._info ~= format("%s %s: (%s) %s", prefix, caption, T.stringof, value);
	}

	/**
	 * Add a line of expected info to the exception.
	 */
	public void addExpectation(T)(string caption, T value, string prefix = "✓")
	{
		this.addInfo!(T)(caption, value, prefix);
	}

	/**
	 * Add a line of typed expected info to the exception.
	 */
	public void addTypedExpectation(T)(string caption, T value, string prefix = "✓")
	{
		this.addTypedInfo!(T)(caption, value, prefix);
	}

	/**
	 * Add a line of error info to the exception.
	 */
	public void addError(T)(string caption, T value, string prefix = "✗")
	{
		this.addInfo!(T)(caption, value, prefix);
	}

	/**
	 * Add a line of typed error info to the exception.
	 */
	public void addTypedError(T)(string caption, T value, string prefix = "✗")
	{
		this.addTypedInfo!(T)(caption, value, prefix);
	}

	/**
	 * String representation.
	 */
	override public string toString()
	{
		string horizontalLine = "+--------------------------------------------------------------------------------";
		string text = "\n";
		text ~= format("%s\n", horizontalLine);
		text ~= format("| %s\n", this.msg);
		text ~= format("%s\n", horizontalLine);
		text ~= format("| File: %s\n", this.file);
		text ~= format("| Line: %s\n", this.line);
		text ~= format("%s\n", horizontalLine);
		foreach (info; this._info)
		{
			text ~= format("| %s\n", info);
		}
		return text;
	}
}
