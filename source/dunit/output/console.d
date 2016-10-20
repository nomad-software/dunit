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
import dunit.error;
import dunit.result.moduleresultcollection;
import std.array;
import std.conv;
import std.range;
import std.stdio;
import std.string;

/**
 * Format output to the console.
 */
class Console
{
	/**
	 * Write a line to the console.
	 *
	 * params:
	 *     line = The line to write.
	 */
	public void write(string line)
	{
		writefln("%s", line);
	}

	/**
	 * Write an indented line to the console.
	 *
	 * params:
	 *     line = The line to write.
	 *     indent = The space indent before the line.
	 */
	public void write(string line, int indent)
	{
		this.write(format("%s%s", " ".repeat(indent).join(), line));
	}

	/**
	 * Write a prefixed line to the console.
	 *
	 * params:
	 *     prefix = The prefix of the line.
	 *     line = The line to write.
	 */
	public void write(string prefix, string line)
	{
		this.write(format("%s %s", prefix, line));
	}

	/**
	 * Write an intented, prefixed line to the console.
	 *
	 * params:
	 *     prefix = The prefix of the line.
	 *     line = The line to write.
	 *     indent = The space indent before the line.
	 */
	public void write(string prefix, string line, int indent)
	{
		this.write(format("%s%s %s", " ".repeat(indent).join(), prefix, line));
	}

	/**
	 * Write the header.
	 */
	public void writeHeader()
	{
		this.write("");
		this.write(">", "Running unit tests");
	}

	/**
	 * Format and write an error to the console.
	 *
	 * Params:
	 *     ex = The exception to output.
	 */
	private void writeError(DUnitAssertError ex)
	{
		this.write("");
		this.write("+----------------------------------------------------------------------", 2);
		this.write("|", ex.msg, 2);
		this.write("+----------------------------------------------------------------------", 2);
		this.write("| File:", ex.file, 2);
		this.write("| Line:", ex.line.text(), 2);
		this.write("+----------------------------------------------------------------------", 2);
		foreach (info; ex.log)
		{
			this.write("|", info, 2);
		}
		this.write("");
	}

	/**
	 * Output a detailed report.
	 *
	 * Params:
	 *     results = A module result collection.
	 */
	public void writeReport(ModuleResultCollection results)
	{
		foreach (result; results)
		{
			this.write("-", result.source);

			if (result.error)
			{
				this.writeError(result.error);
			}
		}

		if (results.failedCount())
		{
			this.write(">", format("%s tests run. %s passed, %s failed",
				results.totalCount(),
				results.passedCount(),
				results.failedCount()
			));
		}
		else
		{
			this.write(">", format("All %s tests passed", results.totalCount()));
		}
	}
}
