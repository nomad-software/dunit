/**
 * Internal reflection templates for implementing mocking behaviour.
 *
 * License:
 *     MIT. See LICENSE.txt for full details.
 */
module dunit.reflection;

/**
 * Imports.
 */
import dunit.toolkit;
import std.range;
import std.string;
import std.traits;

/**
 * Generate a string containing the protection level of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodProtection(func...) if (func.length == 1 && isCallable!(func))
{
	enum MethodProtection = __traits(getProtection, func);
}

unittest
{
	class T
	{
		public void method1(){}
		protected void method2(){}
		private void method3(){}
	}

	MethodProtection!(T.method1).assertEqual("public");
	MethodProtection!(T.method2).assertEqual("protected");
	MethodProtection!(T.method3).assertEqual("private");
}

/**
 * Generate a string containing the attributes of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodAttributes(func...) if (func.length == 1 && isCallable!(func))
{
	private string getMethodAttributes()
	{
		string code = "";

		static if (functionAttributes!(func) & FunctionAttribute.property)
		{
			code ~= "@property ";
		}

		static if (functionAttributes!(func) & FunctionAttribute.trusted)
		{
			code ~= "@trusted ";
		}

		static if (functionAttributes!(func) & FunctionAttribute.safe)
		{
			code ~= "@safe ";
		}

		static if (functionAttributes!(func) & FunctionAttribute.pure_)
		{
			code ~= "pure ";
		}

		static if (functionAttributes!(func) & FunctionAttribute.nothrow_)
		{
			code ~= "nothrow ";
		}

		static if (functionAttributes!(func) & FunctionAttribute.ref_)
		{
			code ~= "ref ";
		}

		return code;
	}
	enum MethodAttributes = getMethodAttributes();
}

unittest
{
	class T
	{
		public @property @trusted void method1(){}
		public @safe pure nothrow void method2(){}
		public ref int method3(ref int foo){return foo;}
	}

	MethodAttributes!(T.method1).assertEqual("@property @trusted ");
	MethodAttributes!(T.method2).assertEqual("@safe pure nothrow ");
	MethodAttributes!(T.method3).assertEqual("ref ");
}

/**
 * Generate a string containing the return type of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodReturnType(func...) if (func.length == 1 && isCallable!(func))
{
	enum MethodReturnType = ReturnType!(func).stringof;
}

unittest
{
	class T
	{
		public int method1(){return 1;}
		public string method2(){return "foo";}
		public char method3(){return 'a';}
	}

	MethodReturnType!(T.method1).assertEqual("int");
	MethodReturnType!(T.method2).assertEqual("string");
	MethodReturnType!(T.method3).assertEqual("char");
}

/**
 * Generate a string containing the name of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodName(func...) if (func.length == 1 && isCallable!(func))
{
	enum MethodName = __traits(identifier, func);
}

unittest
{
	class T
	{
		public void method1(){}
		public void method2(){}
		public void method3(){}
	}

	MethodName!(T.method1).assertEqual("method1");
	MethodName!(T.method2).assertEqual("method2");
	MethodName!(T.method3).assertEqual("method3");
}

/**
 * Generate a string array containing the storage classes of each parameter (if any) of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodParameterStorageClasses(func...) if (func.length == 1 && isCallable!(func))
{
	private string[] getMethodParameterStorageClasses()
	{
		string[] storageClasses;
		string code;

		foreach (storageClass; ParameterStorageClassTuple!(func))
		{
			code = "";

			static if (storageClass == ParameterStorageClass.scope_)
			{
				code ~= "scope ";
			}

			static if (storageClass == ParameterStorageClass.lazy_)
			{
				code ~= "lazy ";
			}

			static if (storageClass == ParameterStorageClass.out_)
			{
				code ~= "out ";
			}

			static if (storageClass == ParameterStorageClass.ref_)
			{
				code ~= "ref ";
			}

			storageClasses ~= code;
		}

		return storageClasses;
	}
	enum MethodParameterStorageClasses = getMethodParameterStorageClasses();
}

unittest
{
	class T
	{
		public void method1(scope int foo){}
		public void method2(lazy int bar){}
		public void method3(out int baz){}
		public void method4(ref int qux){}
	}

	MethodParameterStorageClasses!(T.method1).assertEqual(["scope "]);
	MethodParameterStorageClasses!(T.method2).assertEqual(["lazy "]);
	MethodParameterStorageClasses!(T.method3).assertEqual(["out "]);
	MethodParameterStorageClasses!(T.method4).assertEqual(["ref "]);
}

/**
 * Generate a string array containing the parameter types of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodParameterTypes(func...) if (func.length == 1 && isCallable!(func))
{
	private string[] getMethodParameterTypes()
	{
		string[] types;

		foreach (type; ParameterTypeTuple!(func))
		{
			types ~= type.stringof;
		}

		return types;
	}
	enum MethodParameterTypes = getMethodParameterTypes();
}

unittest
{
	class T
	{
		public void method1(const int foo){}
		public void method2(string bar){}
		public void method3(bool baz){}
	}

	MethodParameterTypes!(T.method1).assertEqual(["const(int)"]);
	MethodParameterTypes!(T.method2).assertEqual(["string"]);
	MethodParameterTypes!(T.method3).assertEqual(["bool"]);
}

/**
 * Generate a string array containing the parameter identifiers of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodParameterIdentifiers(func...) if (func.length == 1 && isCallable!(func))
{
	private string[] getMethodParameterIdentifiers()
	{
		string[] names;

		foreach (name; ParameterIdentifierTuple!(func))
		{
			names ~= name;
		}

		return names;
	}
	enum MethodParameterIdentifiers = getMethodParameterIdentifiers();
}

unittest
{
	class T
	{
		public void method1(const int foo){}
		public void method2(string bar){}
		public void method3(bool baz){}
	}

	MethodParameterIdentifiers!(T.method1).assertEqual(["foo"]);
	MethodParameterIdentifiers!(T.method2).assertEqual(["bar"]);
	MethodParameterIdentifiers!(T.method3).assertEqual(["baz"]);
}

/**
 * Generate a string array containing the default values of each parameter (if any) of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodParameterDefaultValues(func...) if (func.length == 1 && isCallable!(func))
{
	private string[] getMethodParameterDefaultValues()
	{
		string[] defaultValues;

		foreach (defaultValue; ParameterDefaultValueTuple!(func))
		{
			static if (is(defaultValue == void))
			{
				defaultValues ~= "";
			}
			else
			{
				defaultValues ~= " = " ~ defaultValue.stringof;
			}
		}

		return defaultValues;
	}
	enum MethodParameterDefaultValues = getMethodParameterDefaultValues();
}

unittest
{
	class T
	{
		public void method1(const int foo){}
		public void method2(string bar = "qux"){}
		public void method3(bool baz = true){}
	}

	MethodParameterDefaultValues!(T.method1).assertEqual([""]);
	MethodParameterDefaultValues!(T.method2).assertEqual([" = \"qux\""]);
	MethodParameterDefaultValues!(T.method3).assertEqual([" = true"]);
}

/**
 * Generate a string containing the full parameter signature of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodParameters(func...) if (func.length == 1 && isCallable!(func))
{
	private string getMethodParameters()
	{
		string[] storageClasses = MethodParameterStorageClasses!(func);
		string[] types          = MethodParameterTypes!(func);
		string[] names          = MethodParameterIdentifiers!(func);
		string[] defaultValues  = MethodParameterDefaultValues!(func);

		string[] parameters;

		foreach (storageClass, type, name, defaultValue; zip(storageClasses, types, names, defaultValues))
		{
			parameters ~= format("%s%s %s%s", storageClass, type, name, defaultValue);
		}

		return format("(%s)", parameters.join(", "));
	}
	enum MethodParameters = getMethodParameters();
}

unittest
{
	class T
	{
		public void method1(const int foo){}
		public void method2(string bar = "qux"){}
		public void method3(bool baz = true){}
	}

	MethodParameters!(T.method1).assertEqual("(const(int) foo)");
	MethodParameters!(T.method2).assertEqual("(string bar = \"qux\")");
	MethodParameters!(T.method3).assertEqual("(bool baz = true)");
}

/**
 * Generate a string containing the mangled name of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodMangledName(func...) if (func.length == 1 && isCallable!(func))
{
	enum MethodMangledName = mangledName!(func);
}

/**
 * Generate a string containing the body of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodBody(func...)
{
	private string getMethodBody()
	{
		string code = "";
		code ~= "\ttry\n";
		code ~= "\t{\n";
		code ~= "\t\tif (\"" ~ MethodSignature!(func) ~ "\" in this._methodCount)\n";
		code ~= "\t\t{\n";
		code ~= "\t\t\tthis._methodCount[\"" ~ MethodSignature!(func) ~ "\"].actual++;\n";
		code ~= "\t\t}\n";
		code ~= "\t\tif (this." ~ MethodMangledName!(func) ~ ")\n";
		code ~= "\t\t{\n";
		code ~= "\t\t\treturn this." ~ MethodMangledName!(func) ~ "(" ~ MethodParameterIdentifiers!(func).join(", ") ~ ");\n";
		code ~= "\t\t}\n";
		code ~= "\t\telse\n";
		code ~= "\t\t{\n";
		code ~= "\t\t\tif (this._useParentMethods)\n";
		code ~= "\t\t\t{\n";
		code ~= "\t\t\t\treturn super." ~ MethodName!(func) ~ "(" ~ MethodParameterIdentifiers!(func).join(", ") ~ ");\n";
		code ~= "\t\t\t}\n";
		code ~= "\t\t\telse\n";
		code ~= "\t\t\t{\n";
		code ~= "\t\t\t\tauto error = new DUnitAssertError(\"Mock method not implemented\", this._disableMethodsLocation.file, this._disableMethodsLocation.line);\n";
		code ~= "\t\t\t\terror.addInfo(\"Method\", this.className ~ \"." ~ MethodSignature!(func) ~ "\");\n";
		code ~= "\t\t\t\tthrow error;\n";
		code ~= "\t\t\t}\n";
		code ~= "\t\t}\n";
		code ~= "\t}\n";
		code ~= "\tcatch(Exception ex)\n";
		code ~= "\t{\n";
		code ~= "\t\tassert(false, ex.msg);\n";
		code ~= "\t}\n";
		code ~= "\tassert(false, \"Critical error occurred!\");\n";
		return code;
	}
	enum MethodBody = getMethodBody();
}

/**
 * Generate a string containing the code for a delegate property.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodDelegateProperty(func...) if (func.length == 1 && isCallable!(func))
{
	private string getMethodDelegateProperty()
	{
		string[] storageClasses = MethodParameterStorageClasses!(func);
		string[] types          = MethodParameterTypes!(func);
		string[] parameters;

		foreach (storageClass, type; zip(storageClasses, types))
		{
			parameters ~= format("%s%s", storageClass, type);
		}

		return format("private %s %s;\n", MethodDelegateSignature!(func), MethodMangledName!(func));
	}
	enum MethodDelegateProperty = getMethodDelegateProperty();
}

/**
 * Generate a string containing the entire override code for the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template Method(func...) if (func.length == 1 && isCallable!(func))
{
	private string getMethod()
	{
		string code = "";
		code ~= "override ";
		code ~= MethodProtection!(func) ~ " ";
		code ~= MethodAttributes!(func);
		code ~= MethodReturnType!(func) ~ " ";
		code ~= MethodName!(func);
		code ~= MethodParameters!(func) ~ "\n";
		code ~= "{\n";
		code ~= MethodBody!(func);
		code ~= "}\n";
		return code;
	}
	enum Method = getMethod();
}

/**
 * Iterate through the methods of T generating code using the generator.
 *
 * Params:
 *     T = The class to inspect.
 *     generator = The template to use to generate code for each method.
 *     index = The beginning index of the members.
 */
public template DUnitMethodIterator(T, string generator, int index = 0) if (is(T == class))
{
	private string getResult()
	{
		string code = "";
		static if (index < __traits(allMembers, T).length)
		{
			static if (MemberFunctionsTuple!(T, __traits(allMembers, T)[index]).length)
			{
				foreach (func; __traits(getVirtualMethods, T, __traits(allMembers, T)[index]))
				{
					static if (!__traits(isFinalFunction, func))
					{
						mixin("code ~= " ~ generator ~ ";");
					}
				}
			}
			code ~= DUnitMethodIterator!(T, generator, index + 1);
		}
		return code;
	}
	enum DUnitMethodIterator = getResult();
}

/**
 * Generate a string containing the entire override code for the passed constructor.
 *
 * Params:
 *     T = The class to inspect.
 *     func = The function to inspect.
 */
private template Constructor(T, func...) if (is(T == class) && func.length == 1 && isCallable!(func))
{
	private string getConstructor()
	{
		string code = "";
		code ~= "this";
		code ~= MethodParameters!(func) ~ "\n";
		code ~= "{\n";
		code ~= "\tsuper(" ~ MethodParameterIdentifiers!(func).join(", ") ~ ");\n";
		code ~= "}\n";
		return code;
	}
	enum Constructor = getConstructor();
}

unittest
{
	class T
	{
		this(int foo, int bar)
		{
		}
	}

	string code = "this(int foo, int bar)
{
	super(foo, bar);
}\n";

	Constructor!(T, T.__ctor).assertEqual(code);
}

/**
 * Iterate through the constructors of T generating code using the generator.
 *
 * Params:
 *     T = The class to inspect.
 *     generator = The template to use to generate code for each constructor.
 */
public template DUnitConstructorIterator(T, string generator) if (is(T == class))
{
	private string getResult()
	{
		string code = "";
		static if (__traits(hasMember, T, "__ctor"))
		{
			foreach (func; __traits(getOverloads, T, "__ctor"))
			{
				mixin("code ~= " ~ generator ~ ";");
			}
		}
		return code;
	}
	enum DUnitConstructorIterator = getResult();
}

unittest
{
	class A
	{
		this(){}
		this(int foo, int bar)
		{
		}
	}

	class B {}

	string code = "this()
{
	super();
}
this(int foo, int bar)
{
	super(foo, bar);
}\n";

	DUnitConstructorIterator!(A, "Constructor!(T, func)").assertEqual(code);
	DUnitConstructorIterator!(B, "Constructor!(T, func)").assertEqual("");
}

/**
 * Generate a string containing the parameter signature of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodParameterSignature(func...) if (func.length == 1 && isCallable!(func))
{
	private string getMethodParameterSignature()
	{
		string[] storageClasses = MethodParameterStorageClasses!(func);
		string[] types          = MethodParameterTypes!(func);
		string[] parameters;

		foreach (storageClass, type; zip(storageClasses, types))
		{
			parameters ~= format("%s%s", storageClass, type);
		}

		return parameters.join(", ");
	}
	enum MethodParameterSignature = getMethodParameterSignature();
}

unittest
{
	class T
	{
		public void method1(const int foo, string bar){}
		public void method2(string baz, bool qux){}
		public void method3(ref char quux){}
	}

	MethodParameterSignature!(T.method1).assertEqual("const(int), string");
	MethodParameterSignature!(T.method2).assertEqual("string, bool");
	MethodParameterSignature!(T.method3).assertEqual("ref char");
}

/**
 * Generate a string containing the signature of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodSignature(func...) if (func.length == 1 && isCallable!(func))
{
	private string getMethodSignature()
	{
		return format("%s:%s(%s)", MethodReturnType!(func), MethodName!(func), MethodParameterSignature!(func));
	}
	enum MethodSignature = getMethodSignature();
}

unittest
{
	class T
	{
		public int method1(const int foo, string bar){return 1;}
		public void method2(string baz, bool qux){}
		public bool method3(ref char quux){return true;}
	}

	MethodSignature!(T.method1).assertEqual("int:method1(const(int), string)");
	MethodSignature!(T.method2).assertEqual("void:method2(string, bool)");
	MethodSignature!(T.method3).assertEqual("bool:method3(ref char)");
}

/**
 * Generate a string containing the delegate signature of the passed function.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodDelegateSignature(func...) if (func.length == 1 && isCallable!(func))
{
	private string getMethodDelegateSignature()
	{
		return format("%s delegate(%s)", MethodReturnType!(func), MethodParameterSignature!(func));
	}
	enum MethodDelegateSignature = getMethodDelegateSignature();
}

unittest
{
	class T
	{
		public void method1(const int foo, string bar){}
		public void method2(string baz, bool qux){}
		public void method3(ref char quux){}
	}

	MethodDelegateSignature!(T.method1).assertEqual("void delegate(const(int), string)");
	MethodDelegateSignature!(T.method2).assertEqual("void delegate(string, bool)");
	MethodDelegateSignature!(T.method3).assertEqual("void delegate(ref char)");
}

/**
 * Generate a string containing the signature switch.
 *
 * Params:
 *     func = The function to inspect.
 */
private template MethodSignatureSwitch(func...) if (func.length == 1 && isCallable!(func))
{
	private string getMethodSignatureSwitch()
	{
		string code = "";
		code ~= "case \"" ~ MethodSignature!(func) ~ "\":\n";
		code ~= "\tthis." ~ MethodMangledName!(func) ~ " = cast(" ~ MethodDelegateSignature!(func) ~ ")method;\n";
		code ~= "\tbreak;\n";
		return code;
	}
	enum MethodSignatureSwitch = getMethodSignatureSwitch();
}
