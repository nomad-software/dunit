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
	 * Indicate if the collection is empty.
	 *
	 * Returns:
	 *     true if the collection is empty, false if not.
	 */
	public bool empty()
	{
		return !this._results.length;
	}

	/**
	 * The total number of tests in the collection.
	 *
	 * Returns:
	 *     the number of tests that dunit has run.
	 */
	public size_t totalCount()
	{
		return this._results.length;
	}

	/**
	 * The amount of tests that contain a DUnitAssertError.
	 *
	 * Returns:
	 *     the number of tests that have failed.
	 */
	public size_t failedCount()
	{
		return this._results.count!(result => result.error !is null);
	}

	/**
	 * The amount of tests that don't contain a DUnitAssertError.
	 *
	 * Returns:
	 *     the number of tests that have passed.
	 */
	public size_t passedCount()
	{
		return this._results.count!(result => result.error is null);
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
		this._results.multiSort!("a.error is null && b.error !is null", "a.source < b.source")();
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
	results.empty().assertTrue();

	results.add(new ModuleResult("Module1"));
	results.totalCount().assertEqual(1);
	results.failedCount().assertEqual(0);
	results.passedCount().assertEqual(1);

	results.add(new ModuleResult("Module2", new DUnitAssertError("Message", "file.d", 1)));
	results.totalCount().assertEqual(2);
	results.failedCount().assertEqual(1);
	results.passedCount().assertEqual(1);

	results.empty().assertFalse();
	results[].assertCount(2);

	results[0].source.assertEqual("Module1");
	results[0].error.assertNull();
	results[1].source.assertEqual("Module2");
	results[1].error.assertType!(DUnitAssertError)();
}
