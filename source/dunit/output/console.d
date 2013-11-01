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
import std.stdio;
import std.string;
version(ColorOutput)
{
    import dunit.output.consoled;
    alias Error = ColorTheme!(Color.red, Color.initial);
    alias Warning= ColorTheme!(Color.yellow, Color.initial);
    alias Info  = ColorTheme!(Color.green, Color.initial);
}
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
        version(ColorOutput)
        {   title = "DUnit running unit tests...";
            writeln();
            writecln("DUnit by Gary Willoughby.".Info);
            writecln("> Running unit tests".Info);
        } else {
            writeln("");
            writeln("DUnit by Gary Willoughby.");
            writeln("> Running unit tests");
        }
	}

	/**
	 * Write the success message.
	 */
	public void writeSuccessMessage()
	{
        version(ColorOutput)
            writecln("> Success".Info);
        else
            writeln("> Success");
	}

	/**
	 * Write the fail message.
	 */
	public void writeFailMessage()
	{
        version(ColorOutput)
            writecln("> Failed".Error);
        else
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
        version(ColorOutput)
        {
            string horizontalLine = "+";
            foreach(num; 0..size.x-1)
                horizontalLine ~= "-";

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
            text ~= format("%s\n", horizontalLine);
            writec(text.Error);
        } else {
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
