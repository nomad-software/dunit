/**
 * Module to handle output to the console.
 *
 * License:
 *     MIT. See LICENSE.txt for full details.
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
		writeln("Running unit tests");
		writeln("");
	}

	/**
	 * Write the success message.
	 */
	public void writeSuccess()
	{
		writeln("✓ Success");
	}

	/**
	 * Output a detailed report.
	 *
	 * Params:
	 *     results = An array of results.
	 */
	public void writeOverview(DUnitAssertError[string] results)
	{
		foreach (moduleName, error; results)
		{
			writefln("%s, %s", moduleName, (error is null));
		}
	}

	/**
	 * Output a detailed report.
	 *
	 * Params:
	 *     results = An array of results.
	 */
	public void writeDetail(DUnitAssertError[string] results)
	{
		foreach (moduleName, error; results)
		{
			if (error !is null)
			{
				writeln(error.toString());
			}
		}
	}
}
