part of dartify.generator;

String nativeResolver(prototypes) {
  String comparisons = prototypes.fold('\n', (prev, next) {
    var id = next.id, 
        wrapper = _wrapperId(id);
    return '$prev  if (!strcmp("$id", cname)) return $wrapper;\n';
  });
  return 'Dartify_ResolveName($comparisons)\n';
}

String initializer() => 'Dartify_InitializeExtension()';

String parameterAllocation(parameter, int pos) {
  final type = parameter.type;
  final id = parameter.id;
  String noConstType = type.replaceAll('const', '').trim();

  switch(noConstType) {
    case 'void': return '';

    case 'int':
      return  'error = Dartify_GetIntNativeArgument(arguments, $pos);\n'
              'Dartify_HandleError(error);\n'
              '$type $id = ${_dartifyResultField(type)};\n';
    case 'uint':
      return  'error = Dartify_GetUintNativeArgument(arguments, $pos);\n'
              'Dartify_HandleError(error);\n'
              '$type $id = ${_dartifyResultField(type)};\n';
    case 'mpz_t':
      return  'error = Dartify_GetMpzNativeArgument(arguments, $pos);\n'
              'Dartify_HandleError(error);\n'
              '$type $id;\n'
              '${_gmpSimInitializer(type)}($id, ${_dartifyResultField(type)});\n';
    case 'mpz_f':
      return  'error = Dartify_GetMpfNativeArgument(arguments, $pos);\n'
              'Dartify_HandleError(error);\n'
              '$type $id;\n'
              '${_gmpSimInitializer(type)}($id, ${_dartifyResultField(type)});\n';
    case 'double':
      return  'error = Dartify_GetDoubleNativeArgument(arguments, $pos);\n'
              'Dartify_HandleError(error);\n'
              '$type $id = ${_dartifyResultField(type)};\n';
    case 'bool':
      return  'error = Dartify_GetBooleanNativeArgument(arguments, $pos);\n'
              'Dartify_HandleError(error);\n'
              '$type $id = ${_dartifyResultField(type)};\n';
    default: throw new UnsupportedError('Unsupported paremeter type "$type" for "$id"');
  }
}

String parameterList(parameters) {
  if (parameters == null) return '';

  return parameters.fold('', (prev, next) {
    String id = next.id;
    return '$prev, $id';
  }).substring(2);
}

String returnStatement(id, type, pointer) {
  if (pointer != null && pointer.length > 1) {
    throw new UnsupportedError('function $id has invalid return type "$type"');
  }
  
  switch(type) {
    case 'int': return 'Dart_SetIntegerReturnValue(arguments, $id);\n'; break;
    case 'uint': return 'Dart_SetIntegerReturnValue(arguments, $id);\n'; break;
    case 'mpz_t': return 'Dartify_SetIntegerReturnValueFromMpz(arguments, $id);\n'; break;
    case 'double': return 'Dart_SetDoubleReturnValue(arguments, $id);\n'; break;
    case 'bool': return 'Dart_SetBooleanReturnValue(arguments, $id);\n'; break;
    case 'void': return ''; break;
    default: throw new UnsupportedError('$id has invalid return type "$type"');
  }
}

String _wrapper(id, allocations, execution, returnStmt, cleanup) =>
  'void ${_wrapperId(id)} (Dart_NativeArguments arguments) {\n' +
  _indent(
    'Dart_EnterScope();\n'
    'Dart_Handle error;\n'
    '$allocations\n'
    '$execution\n'
    '$returnStmt\n'
    '$cleanup\n'
    'Dart_ExitScope();\n') +
  '}\n';

/**
 * Fails if the supplied prototype fails to conform to gmp extension standards
 * such as having a non-void return type or an initial parameter of an invalid
 * type.
 */
void _ensureValidGmpPrototype(prototype) {
  var parameters = prototype.parameters,
      type = prototype.type,
      id = prototype.id,
      message,
      culprit;

  if (parameters == null) {
    message = 'A gmp exort must accept at least one parameter as the return value of the extension';
    culprit = '$type $id';
    throw new ParameterException(message, culprit);
  }

  if (!_isGmpType(parameters.first.type)) {
    message = 'first parameter of gmp export must be multiprecision type (see gmp.h)';
    culprit = '$type $id';
    throw new ParameterException(message, culprit);
  }

  if (type != 'void') {
    message = 'A gmp export must return void';
    culprit = '$type $id';
    throw new ReturnTypeException(message, culprit);
  }
}

/**
 * Wraps a function in a synchronous dart native extension that returns a 
 * gmp data structure. An exported gmp function must have a return type of void
 * and its first argument must be one of the multiple precision types defined
 * in the gmp.h header file. This first argument is allocated, returned and
 * freed by dartify.  The user of the generated library will not be required
 * or able to pass this parameter manually.
 */
String synchronousGmpFunctionWrapper(prototype) {
  _ensureValidGmpPrototype(prototype);

  var type = prototype.type,
      pointer = prototype.pointer,
      id = prototype.id,
      parameters = prototype.parameters,
      rettype = parameters.first.type,
      retid = parameters.first.id,
      allocations,
      execution,
      cleanup,
      returnStmt;
      
  // This should handle more than just mpz_t
  allocations = '$rettype $retid;\n'
                '${_gmpInitializer(rettype)}($retid);\n'
                '${_gmpInitializer(rettype)}(${_dartifyResultField(rettype)});';

  // skip first argument. Dartify will manage it.
  for (int i=1; i < parameters.length; i++) {
    allocations = "$allocations\n${parameterAllocation(parameters[i], i-1)}";
  }

  execution = '$id(${parameterList(parameters)});';
  returnStmt = returnStatement(retid, rettype, pointer);
  cleanup = '${_gmpDestructor(rettype)}($retid);\n'
            '${_gmpDestructor(rettype)}(${_dartifyResultField(rettype)});';

  return _wrapper(id, allocations, execution, returnStmt, cleanup);
}

/**
 * Wraps a function in a synchronous dart native extension.
 */
String synchronousFunctionWrapper(prototype) {
  var type = prototype.type,
      pointer = prototype.pointer,
      id = prototype.id,
      parameters = prototype.parameters,
      allocations = '',
      execution,
      returnStmt = '';

  if (parameters != null) {
    for (int i=0; i<parameters.length; i++) {
      allocations = "$allocations\n${parameterAllocation(parameters[i], i)}";
    }
  }

  execution = (type == 'void' && pointer.isEmpty)
    ? '$id(${parameterList(parameters)});'
    : '$type result = $id(${parameterList(parameters)});';

  returnStmt = returnStatement("result", type, pointer);

  return _wrapper(id, allocations, execution, returnStmt, '');
}
