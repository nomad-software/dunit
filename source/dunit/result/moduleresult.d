/**
 * Module to contain the module result class.
 *
 * License:
 *     MIT. See LICENSE for full details.
 */
module dunit.result.moduleresult;

/**
 * Imports.
 */
import dunit.error;

/**
 * A class to contain the result from running a module's unit tests.
 */
class ModuleResult
{
	/**
	 * The name of the module which ran the unit test.
	 */
	private string _source;

	/**
	 * The first error that occurred. If this is null, no errors occurred when running the modules unit tests.
	 * A module stops running any remaining unit tests if one throws an error.
	 */
	private DUnitAssertError _error;

	/**
	 * Constructor.
	 *
	 * Params:
	 *     name = The name of the module who's unit tests where run.
	 *     error = An error, if it occurred.
	 */
	this(string name, DUnitAssertError error = null)
	{
		this._source = name;
		this._error  = error;
	}

	/**
	 * Access the name of the module.
	 *
	 * Returns:
	 *     The name of the module that produced this result.
	 */
	public @property string source()
	{
		return this._source;
	}

	/**
	 * Access the error if one occurred.
	 *
	 * Returns:
	 *     The error if one occurred, null if not.
	 */
	public @property DUnitAssertError error()
	{
		return this._error;
	}
}

unittest
{
	import dunit.toolkit;

	auto result = new ModuleResult("Module", new DUnitAssertError("Message", "file.d", 1));
	result.source.assertEqual("Module");
	result.error.msg.assertEqual("Message");
	result.error.file.assertEqual("file.d");
	result.error.line.assertEqual(1);
	result.error.log.assertEqual([]);
}
