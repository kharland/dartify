# Dartify

Dartify lets you write C code and wrap it as a dart native extension without writing any dart_api library code by hand.  Just wrap your existing C code and run it from dart.

### Dependencies 
  - libgmp 5.x.x
  
### Installing

Activate the package globally for simple use:

```dart
pub global active dartify
```

For now, you also need to create a symbolic link to `dartify.h` in the directory that your extension will be compiled in because the generated extension will contain this line: `#include 'dartify.h'`.  `dartify.h` is in `(DARTIFY_HOME)/packages/dartify/`.  This is only temporary and will be handled automatically in future releases.

### Usage

In order to make a C function callable from dart, you have to annotate the function to let Dartify know that you want it to become part of your extension. To make a synchronous extension you must use the `//@dartify:sync` annotation. So to export the function `foo` from this C code as a synchronous extension:

```c
bool foo(int bar) {
  return bar == 0;
}
```

You must simply add the annotation:

```c
//@dartify:sync
bool foo(int bar) {
  return bar == 0;
}
```

You can annotate multiple functions in the same file and they will all be wrapped in the C extension that is generated.

If this code is in some file called `code.cc` then you can generate the extension for this file like so:

```dart
dartify code.cc > code_extension.cc
```

Now you can compile `code_extension.cc` to a shared library and use it as a dart native extension! For tips on compiling, see the [Dart Native Extension tutorial](https://www.dartlang.org/articles/native-extensions-for-standalone-dart-vm/)

Dartify uses libgmp to account for some compatibility issus between C and Dart, so be aware that when compiling you must use the option `-lgmp` to link against the gmp binaries.

### Making up for numbers in C

C does not support numbers of arbitrary size, but dart does.  This means that if the user passes an integer requiring more than 32 or 64 bits of precision (depending on the machine) then your function might experience some wraparound.

Dartify gets around this problem by using [libgmp](https://gmplib.org/manual/).  If your function requires numbers of arbitrary size then you will need to follow the conventions for handling gmp data structures.

### GMP Conventions

A function returning any gmp type must be annotated with `//@dartify:syncgmp` for a synchronous extension or `//@dartify:asyncgmp` for an asynchronous extension.  The function must have a return type of void and the first parameter to the function must be the result that you wish to return to the dart runtime.

##### Integers

The gmp type for an integer is `mpz_t`.  To give an example of a wrappable function which properly follows the above conventions, take a look at `add` below.  It adds two gmp integer types and stores the result in the first parameter.

```c
//@dartify:syncgmp
void add(mpz_t sum, mpz_t a, mpz_t b) {
  mpz_add(sum, a, b);
}
```

Dartify will make sure that the value stored in `sum` gets returned as an integer.  When the user calls your function from dart, they will not supply the first parameter.  Dartify will initialize, free and return the value of the variable as necessary.  For example, your dart code will look something like this:

```dart
import 'dart-ext:code_extension';

int add(int a, int b) native "add";

main() {
  int x = pow(2, 64);
  int y = pow(2, 64);
  print(add(x, y)); // outputs 36893488147419103232
}
```

##### Doubles

Because Dart [only supports 64-bit floating point numbers](https://www.dartlang.org/articles/numeric-computation/#floating-point-numbers), functions returning double and float values do not have any special standards that need to be met.  If the Dart VM changes in the future to handle floating point values of arbitrary precision then Dartify may utilize the mpf_t type from libgmp.

### Annotations

**@dartify:sync**  
Wraps the annotated function in a synchronous dart extension

**@dartify:async**  
*Not yet supported*

**@dartify:syncgmp**  
Wraps the annotated function in a synchronous dart extension that expects a libgmp data structure to be returned. The function itself must return void and the first parameter must be the return value handed back to the dart runtime.

**@dartify:asyncgmp**  
*Not yet supported*

### Planned feature support
- [x] int parameters
- [x] int return type
- [x] uint parameters
- [x] uint return type
- [x] double parameters
- [x] double return type
- [x] float parameters
- [x] float return type
- [x] bool parameters
- [x] bool return type
- [x] String (const char *) parameters
- [x] String (const char *) return type
- [x] Multi-precision integers
- [ ] List parameters
- [ ] List return type
- [ ] Map parameters
- [ ] Map return types
- [ ] Abritrary objects
- [x] Synchronous extension wrappers
- [ ] Asynchronous extension wrappers
- [ ] Recognize K&R style parameter lists
