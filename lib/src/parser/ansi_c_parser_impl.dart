part of dartify.parser;

class _AnsiCParser extends _AnsiCGrammar implements AnsiCParser {  
  parse(String source) => dartifyExport.matchesSkipping(source);

  get ANNOTATION => super.ANNOTATION.map((annotation) {
    annotation = annotation.substring(annotation.indexOf(':') + 1);
    return annotation;
  });

  get parameterDeclaration => super.parameterDeclaration.map((value) {
    var type,
        pointer,
        id;

    if (value[0] != null) type = value[0].join(' ');
    if (value[1] != null) {
      pointer = value[1][0];
      id = value[1][1];
    }

    return new Parameter(type, pointer, id);
  });

  get parameterList => super.parameterList.map((value) {
    value[1] = value[1].map((item) => item.last).toList();
    value[1].insert(0, value[0]);
    return value[1];
  });

  get pointer => super.pointer.map((pointers) {
    pointers = pointers.fold("", (prev, next) => next[1] == null
      ? "$prev${next[0]}"
      : "$prev${next[0]}${next[1][0]}");
    return pointers;
  });

  get directDeclarator => super.directDeclarator.map((value) {
    var id = value[0], 
        params = value[2];
    return [id, params];
  });

  get declarator => super.declarator.map((value) {
    var pointer = value[0] == null ? "" : value[0],
        id = value[1][0],
        params = value[1][1];
    return [pointer, id, params];
  });

  get parameterTypeList => super.parameterTypeList.map((value) {
    var params = value[0],
        tail = value[1];
    if (tail != null) {
      params.add(tail.last); // ellipsis
    }
    return params;
  }); 

  get functionPrototype => super.functionPrototype.map((value) {
    var specifiers = value[0],
        declarator = value[1],
        type = specifiers.join(' '),
        pointer = declarator[0],
        id = declarator[1],
        params = declarator[2];
    return new FunctionPrototype(type, pointer, id, params);
  });

  get dartifyExport => super.dartifyExport.map((value) {
    var annotation = value[0],
        prototype = value[1];
    return new DartifyExport(annotation, prototype);
  });

  static var _cached;

  _AnsiCParser._internal();
  
  factory _AnsiCParser() {
    if (_cached == null) {
      _cached = new _AnsiCParser._internal();
    }
    return _cached;
  }
}
