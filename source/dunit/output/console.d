/**
 * Module to handle output to the console.
 *
 * License:
 *     MIT. See LICENSE for full details.
 */
module dunit.output.console;

/**
 * Imports.
 */
import dunit.exception;
import std.stdio;
import std.string;

/**
 * Format output to the console.
 */
class Console
{
	/**
	 * Write the header.
	 */
	public void writeHeader()
	{
		writeln("");
		writeln("DUnit v1.0b by Gary Willoughby.");
		writeln("> Running unit tests");
	}

	/**
	 * Write the success message.
	 */
	public void writeSuccessMessage()
	{
		writeln("> Success");
	}

	/**
	 * Write the fail message.
	 */
	public void writeFailMessage()
	{
		writeln("> Failed");
	}

	/**
	 * Format and write an exception to the console.
	 *
	 * Params:
	 *     ex = The exception to output.
	 */
	private void writeException(DUnitAssertError ex)
	{
		string horizontalLine = "+----------------------------------------------------------------------";
		string text = "\n";
		text ~= format("%s\n", horizontalLine);
		text ~= format("| %s\n", ex.msg);
		text ~= format("%s\n", horizontalLine);
		text ~= format("| File: %s\n", ex.file);
		text ~= format("| Line: %s\n", ex.line);
		text ~= format("%s\n", horizontalLine);
		foreach (info; ex.log)
		{
			text ~= format("| %s\n", info);
		}
		write(text);
	}

	/**
	 * Output a detailed report.
	 *
	 * Params:
	 *     results = An array of results.
	 */
	public void writeDetailedResults(DUnitAssertError[string] results)
	{
		foreach (ex; results)
		{
			if (ex !is null)
			{
				this.writeException(ex);
			}
		}
	}
}
