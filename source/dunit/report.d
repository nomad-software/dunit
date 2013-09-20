/**
 * Module to handle error reporting.
 *
 * License:
 *     MIT. See LICENSE.txt for full details.
 */
module dunit.report;

/**
 * Imports.
 */
import std.string;

/**
 * Report an error to the command line.
 *
 * Params:
 *     message = The error message to display.
 *     targetTitle = The title of the target value.
 *     target = The target value.
 *     actualTitle = The title of the actual value.
 *     value = The value used during the assertion.
 *     file = The file name where the error occurred. The value is added automatically at the call site.
 *     line = The line where the error occurred. The value is added automatically at the call site.
 */
public void reportError(A, B)(string message, string targetTitle, A target, string actualTitle, B value, string file, ulong line)
{
	string horizontalLine = "+--------------------------------------------------------------------------------";
	string text = "\n";
	text ~= format("%s\n", horizontalLine);
	text ~= format("| %s\n", message);
	text ~= format("%s\n", horizontalLine);
	text ~= format("| File: %s\n", file);
	text ~= format("| Line: %s\n", line);
	text ~= format("%s\n", horizontalLine);
	text ~= format("| ✓ %s %s: %s\n", targetTitle, A.stringof, target);
	text ~= format("| ✗ %s %s: %s", actualTitle, B.stringof, value);
	assert(false, text);
}
