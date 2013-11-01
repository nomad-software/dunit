/**
 * Module to replace the built-in unit tester.
 *
 * License:
 *     MIT. See LICENSE for full details.
 */
module dunit.moduleunittester;

/**
 * Imports.
 */
import core.exception;
import core.runtime;
import dunit.error;
import dunit.output.console;
import dunit.result.moduleresult;
import dunit.result.moduleresultcollection;

/**
 * Replace the standard unit test handler.
 */
version(unittest) shared static this()
{
	Runtime.moduleUnitTester = function()
	{
		auto console = new Console();
		auto results = new ModuleResultCollection();

		console.writeHeader();

		foreach (module_; ModuleInfo)
		{
			if (module_)
			{
				auto unitTest = module_.unitTest;

				if (unitTest)
				{
					try
					{
						unitTest();
					}
					catch (DUnitAssertError ex)
					{
						results.add(new ModuleResult(module_.name, ex));
						continue;
					}
					catch (AssertError ex)
					{
						results.add(new ModuleResult(module_.name, new DUnitAssertError(ex.msg, ex.file, ex.line)));
						continue;
					}
					results.add(new ModuleResult(module_.name));
				}
			}
		}

		console.writeReport(results);

		return results.allSuccessful;
	};
}
