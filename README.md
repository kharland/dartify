# Dartify

Dartify lets you write C code and wrap it as a dart native extension without doing any extra work!  

### Feature support
- [x] Multi-precision integers
- [ ] Lists
- [ ] Maps
- [ ] Abritrary objects
- [x] Synchronous extension wrappers
- [ ] Asynchronous extension wrappers

### Installing

Activate the package globally for simple use:

```dart
pub global active dartify
```

For now, you also need to create a symbolic link to `dartify.h` in the directory that your extension will be compiled in because the generated extension will contain this line: `#include 'dartify.h'`.  `dartify.h` is in `<CURDIR>/packages/dartify/`.  This is only temporary and will be handled automatically in future releases.

### Usage 

In order to make a c function callable from dart, you have to annotate the function to let Dartify know that you want it to become a part of your extension. To make a synchronous extension you must use the `@dartify:sync` annotation. So this C code:

```c
bool foo(int bar) {
  return bar == 0;
}
```

becomes this:

```c
//@dartify:sync
bool foo(int bar) {
  return bar == 0;
}
```

If you've ever used [browserify](https://github.com/substack/node-browserify), the usage is very similar.  If this code is in some file called `my_c_code.c` then you can generate the extension for this file like so:

```dart
dartify my_c_code.c > my_c_extension.cc
```

Now you can compile my_c_extension.cc and use it as a dart native extension! For tips on compiling, see the [Dart Native Extension tutorial](https://www.dartlang.org/articles/native-extensions-for-standalone-dart-vm/)

Dartify uses libgmp to account for some compatibility issus between C and Dart, so remember that when compiling you must use the option `-lgmp` to link against the gmp binaries.

Because Dartify annotations are just comments, you technically don't have to change your C code to get it working.

### Making up for C

C does not support numbers of arbitrary size, but dart does.  This means that if the user passes an integer requiring more than 32 or 64 bits of precision (depending on the machine) then your function might experience some wraparound issues.

Dartify gets around this problem by using [libgmp](https://gmplib.org/manual/).  If your function requires numbers of arbitrary size then you will need to follow the conventions for handling gmp data structures.

### GMP Conventions

A function returning any gmp type must be annotated with `//@dartify:syncgmp` for a synchronous extension or `//@dartify:asyncgmp` for an asynchronous extension.  The function must have a return type of void and the first parameter to the function must be the result that you wish to return to the top-level invocation of your library.

##### Integers

The gmp type for an integer is `mpz_t`.  To give an example of a wrappable function which properly follows the above conventions, take a look at `add` below.  It adds two gmp integer types and stores the result in the first parameter.

```c
//@dartify:syncgmp
void add(mpz_t sum, mpz_t a, mpz_t b) {
  mpz_add(sum, a, b);
}
```

Dartify will make sure that the value stored in `sum` gets returned as an integer.  When the user calls your function from dart, they will not supply the first parameter.  Dartify will initialize, free and return the value of the variable as necessary.  For example, your dart code may look something like this:

```dart
import 'dart-ext:my_c_extension';

int add(int a, int b) native "add";

main() {
  int x = pow(2, 64);
  int y = pow(2, 64);
  print(add(x, y)); // outputs 36893488147419103232
}
```

##### Doubles

Because Dart [only supports 64-bit floating point numbers](https://www.dartlang.org/articles/numeric-computation/#floating-point-numbers), functions returning double and float values do not have any special standards that need to be met.  If the Dart VM changes in the future to handle floating point values of arbitrary precision then Dartify may utilize the mpf_t type from libgmp.
