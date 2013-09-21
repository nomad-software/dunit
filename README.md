# DUnit
**Advanced unit testing toolkit.**

---

DUnit is a unit testing toolkit for the D programming language. The toolkit comprises of a solution to mocking objects and a library to enable more expressive and helpful assertions.

Unit testing is necessary to assert *units* of code perform in isolation and conform to repeatable and known expectations. DUnit gives you the tools to make this task an easier one.

## Supported platforms
DUnit was developed and tested with DMD v2.063.2 and should support any platform DMD supports as it only contains platform independent code. Other compilers have not been tested but should build fine.

## Features

### Object mocking
DUnit features a mixin template to inject mockable behaviour into a class. Once injected a static method allows creation of mock objects from that class. Mock objects behave and act as their parent but with the added feature that all methods can be disabled or replaced by a delegate at runtime. *The mixin only injects code in debug mode.*

### Helpful asserts
In DUnit all errors are handled by asserting false and displaying a helpful error message. When something goes wrong the error tries to be as helpful as possible by showing file, line, and assert value output.

## Compilier flags

### Required
1. Mocking behaviour is only injected in debug mode so you must used the `-debug` flag for mocking to work.
1. Usually when using DUnit all unit testing code is placed within unittest blocks. If this is the case you must compile using the `-unittest` flag to enable their execution.

### Notes
1. Because DUnit uses asserts for error reporting, compiling using `-release` will disable their output. This shouldn't really be an issue as you don't want to be compiling debug information or unittests into a release build.

## Documentation
There is full HTML documentation in the [docs](https://github.com/kalekold/dunit/tree/master/docs) directory.

## Example

[Click here to see a simple example of how Dunit is used.](https://github.com/kalekold/dunit/blob/master/source/example.d)
