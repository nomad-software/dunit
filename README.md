# DUnit
**Advanced unit testing toolkit for the D programming language**

---

DUnit is a unit testing toolkit for the D programming language. The toolkit comprises of a solution to mocking objects and a library to enable more expressive and helpful assertions.

Unit testing is necessary to assert *units* of code perform in isolation and conform to repeatable and known expectations. DUnit gives you the tools to make this task an easier one.

## Supported platforms
DUnit was developed and tested with the latest DMD compiler and should support any platform DMD supports as it only contains platform independent code. Other compilers have not been tested but should build fine.

## Features

### Object mocking
DUnit features a mixin template to inject mockable behaviour into a class or interface. Once injected, a static method allows you to retrieve an object with the same properties as the class or interface it was retrieved from. Mock objects behave and act as their parent (or in the case of interfaces an implemention) but with the added feature that all methods can be replaced by a delegate at runtime*.

* Final methods cannot be replaced.
* The mixin only injects code when the `-unittest` compiler flag is used.

### Helpful asserts
When using DUnit the built-in unit test handler has been replaced to give more helpful error messages. When something goes wrong the error tries to be as helpful as possible by showing file, line, and assert value output.

	DUnit by Gary Willoughby.
	> Running unit tests
	- example

	+----------------------------------------------------------------------
	| Failed asserting equal
	+----------------------------------------------------------------------
	| File: example.d
	| Line: 91
	+----------------------------------------------------------------------
	| ✓ Expected value: (int) 1
	| ✗ Actual value: (ulong) 2

## Compiler flags

### Required
1. Mocking behaviour is only injected in unit test mode so you must used the `-unittest` flag for mocking to work.
1. Usually when using DUnit all unit testing code is placed within unittest blocks. If this is the case you must compile using the `-unittest` flag to enable their execution.

### Notes
1. When compiling using the `-unittest` switch be mindful that standard assert functions will exit the program and display an error, even when compiled with the `-release` switch! To stop this happening, remove the `-unittest` switch from the compile command and `-release` will once again ignore asserts.

## Documentation
There is full HTML documentation within the repository inside the [docs](https://github.com/nomad-software/dunit/tree/master/docs) directory.

### Building with dub
To build DUnit as a static library using [dub](https://github.com/rejectedsoftware/dub) use the following command.

	dub build --build=unittest --config=library

### View online
- [Mockable mixin](http://htmlpreview.github.io/?https://github.com/nomad-software/dunit/master/docs/dunit/mockable.html)
- [Assert toolkit](http://htmlpreview.github.io/?https://github.com/nomad-software/dunit/master/docs/dunit/toolkit.html)

## Example

[Click here to see an example of how Dunit is used.](https://github.com/nomad-software/dunit/blob/master/source/example.d)
