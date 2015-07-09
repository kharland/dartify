part of dartify.generator;

final RegExp _prefixNewline = new RegExp(r'[\n](?!$)');
const int _indent_size = 2;
String _indentation = '';

String _indent(content) => 
  '$_indentation${content.replaceAll(_prefixNewline, "\n$_indentation")}';

void _warn(warning) => stderr.writeln('\nwarning: $warning\n');

void enterBlock() {
  _indentation = _indentation.padRight(_indent_size);
} 

void exitBlock() {
  _indentation = _indentation.substring(_indent_size);
}

String _paramAlloc(param, int pos) {
  final type = param.type;
  final id = param.id;
  String alloc;

  switch (type) {
    case 'void': 
      alloc = '';
      break;
    case 'int':
      alloc = 'error = Dartify_GetIntNativeArgument(arguments, $pos);\n'
            + 'Dartify_HandleError(error);\n'
            + '$type $id = ${_dartifyResultField(type)};';
      break;
    case 'uint':
      alloc = 'error = Dartify_GetUintNativeArgument(arguments, $pos);\n'
            + 'Dartify_HandleError(error);\n'
            + '$type $id = ${_dartifyResultField(type)};';
      break;
    case 'mpz_t':
      alloc = 'error = Dartify_GetMpzNativeArgument(arguments, $pos);\n'
            + 'Dartify_HandleError(error);\n'
            + '$type $id;\n'
            + '${_gmpSimInitializer(type)}($id,${_dartifyResultField(type)});';
      break;
    case 'float':
    case 'double':
      alloc = 'error = Dartify_GetDoubleNativeArgument(arguments, $pos);\n'
            + 'Dartify_HandleError(error);\n'
            + '$type $id = ${_dartifyResultField(type)};';
      break;
    case 'bool':
      alloc = 'error = Dartify_GetBooleanNativeArgument(arguments, $pos);\n'
            + 'Dartify_HandleError(error);\n'
            + '$type $id = ${_dartifyResultField(type)};';
      break;
    case 'const char *':
      alloc = 'error = Dartify_GetNativeStringArgument(arguments, $pos);\n'
            + 'Dartify_HandleError(error);\n'
            + '$type $id = ${_dartifyResultField(type)};';
      break;
    default:
      throw new UnsupportedError('Unsupported paremeter type "$type" for "$id"');
  }

  return alloc;
}

void _ensureValidGmpPrototype(prototype) {
  var parameters = prototype.parameters,
      type = prototype.type,
      id = prototype.id;

  if (parameters == null) {
    throw new ParameterException(
        'A gmp export must accept at least one parameter', '$type $id');
  }

  if (type != 'void') {
    _warn('return value of gmp export "$type $id" will be ignored');
  }
}

String _wrapperProto(prototype) =>
  'void ${_wrapperId(prototype.id)}(Dart_NativeArguments arguments)';

String _wrapperId(id) => 'dw_$id';

String _initializerId(libname) => "${libname}_extension_Init";

String _paramList(parameters) {
  if (parameters == null) return '';
  return parameters.fold('', (params, next) => 
    '$params, ${next.id}').substring(2);
}

String _gmpSimInitializer(type) {
  switch(type) {
    case 'mpz_t': return 'mpz_init_set';
    default: throw new UnsupportedError('setter-initializer not found for type "$type"');
  }
}

String _gmpInitializer(type) {
  switch(type) {
    case 'mpz_t': 
      return 'mpz_init';
    default: 
      throw new UnsupportedError('gmp initializer not found for type "$type"');
  }
}

String _gmpDestructor(type) {
  switch(type) {
    case 'mpz_t': 
      return 'mpz_clear';
    default: 
      throw new UnsupportedError('destructor not found for type "$type"');
  }
}

String _dartifyResultField(type) {
  String R = "dartifyResult";
  switch(type) {
    case 'int':
      return '$R.i';
    case 'uint':
      return '$R.ui';
    case 'double':
      return '$R.d';
    case 'bool':
      return '$R.b';
    case 'mpz_t':
      return '$R.mpz';
    case 'const char *':
      return '$R.str';
    default: 
      throw new UnsupportedError('cannot find dartifyResult field for type "$type"');
  }
}

String _retStmt(type, id) {
  switch (type) {
    case 'void': 
      return '';
      break;
    case 'int':
    case 'uint':
      return 'Dart_SetIntegerReturnValue(arguments, $id);';
      break;
    case 'mpz_t':
      return 'Dartify_SetIntegerReturnValueFromMpz(arguments, $id);';
      break;
    case 'float':
    case 'double':
      return 'Dart_SetDoubleReturnValue(arguments, $id);';
      break;
    case 'bool':
      return 'Dart_SetBooleanReturnValue(arguments, $id);';
      break;
    case 'const char *':
      return 'Dartify_SetStringReturnValue(arguments, $id);';
      break;
    default:
      throw new UnsupportedError('Unsupported return type "$type" for "$id"');
  }
}