part of dartify.generator;

final RegExp prefixNL = new RegExp(r'[\n](?!$)');

String _indent(text) => '  ${text.replaceAll(prefixNL, "\n  ")}';

String _wrapperId(id) => 'dw_$id';

// gmp simultaneous initialization and assignment function
String _gmpSimInitializer(type) {
  switch(type) {
    case 'mpz_t': return 'mpz_init_set';
    case 'mpz_f': return 'mpf_init_set';
    default: throw new UnsupportedError('setter-initializer not found for type "$type"');
  }
}

// gmp initialization function
String _gmpInitializer(type) {
  switch(type) {
    case 'mpz_t': return 'mpz_init';
    default: throw new UnsupportedError('initializer not found for type "$type"');
  }
}

// gmp memory free function
String _gmpDestructor(type) {
  switch(type) {
    case 'mpz_t': return 'mpz_clear';
    default: throw new UnsupportedError('destructor not found for type "$type"');
  }
}

String _dartifyResultField(type) {
  String R = "dartifyResult";
  switch(type) {
    case 'int':    return '$R.i';
    case 'uint':   return '$R.ui';
    case 'double': return '$R.d';
    case 'bool':   return '$R.b';
    case 'mpz_t':  return '$R.mpz';
    default: throw new UnsupportedError('cannot find dartifyResult field for type "$type"');
  }
}

// Supported GMP types
bool _isGmpType(String type) {
  switch(type) {
    case 'mpz_t': return true;
    default: return false;
  }
}