/**
 * Module for the module result collection.
 *
 * License:
 *     MIT. See LICENSE for full details.
 */
module dunit.result.moduleresultcollection;

/**
 * Imports.
 */
import dunit.result.moduleresult;
import std.algorithm;
import std.array;
import std.range;

/**
 * A class to hold module results.
 */
class ModuleResultCollection
{
	/**
	 * Collection of module results.
	 */
	private ModuleResult[] _results;

	/**
	 * Indicate if the results where all successful.
	 *
	 * Returns:
	 *     true if the results where successful, false if not.
	 */
	public @property bool allSuccessful()
	{
		foreach (result; this._results.retro())
		{
			if (result.error)
			{
				return false;
			}
		}
		return true;
	}

	/**
	 * Indicate if the collection is empty.
	 *
	 * Returns:
	 *     true if the collection is empty, false if not.
	 */
	public @property bool empty()
	{
		return this._results.empty();
	}

	/**
	 * Add a result to the collection.
	 *
	 * This method also sorts the collection by source and makes sure all results containing errors are at the end.
	 * This enables the console output to be more user friendly.
	 *
	 * Params:
	 *     result = The module result to add.
	 */
	public void add(ModuleResult result)
	{
		this._results ~= result;
		
		
		// Workaround for a not yet pulled fix in DMD that fixes
		// an issue in conjunction with valgrind.
		// see: 
		//	https://d.puremagic.com/issues/show_bug.cgi?id=12183
		//	https://github.com/D-Programming-Language/phobos/pull/1946
		// original code: 
		// 	this._results.multiSort!("a.error is null && b.error !is null", "a.source < b.source")();
		this._results.sort!("a.error !is b.error ? a.error is null && b.error !is null : a.source < b.source", SwapStrategy.stable)();
	}

	/**
	 * Overload slicing.
	 *
	 * Returns:
	 *     The internal collection of module results.
	 */
	public ModuleResult[] opSlice()
	{
		return this._results;
	}

	/**
	 * Overload indexing.
	 *
	 * Params:
	 *     index = The index of the collection.
	 *
	 * Returns:
	 *     The module result residing at the passed index.
	 */
	public ModuleResult opIndex(size_t index)
	{
		return this._results[index];
	}
}

unittest
{
	import dunit.error;
	import dunit.toolkit;

	auto results = new ModuleResultCollection();
	results.empty.assertTrue();

	results.add(new ModuleResult("Module1"));
	results.allSuccessful.assertTrue();

	results.add(new ModuleResult("Module2", new DUnitAssertError("Message", "file.d", 1)));
	results.allSuccessful.assertFalse();

	results.empty.assertFalse();
	results[].assertCount(2);

	results[0].source.assertEqual("Module1");
	results[0].error.assertNull();
	results[1].source.assertEqual("Module2");
	results[1].error.assertType!(DUnitAssertError)();
}
