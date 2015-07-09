part of dartify.generator;

void write([content='']) => stdout.write(_indent(content));

void writeln([content='']) {
  write(content);
  stdout.writeln();
}

void extensionHeader(infilePath) {
  writeln(
    '#include <string.h>\n'
    '#include "include/dart_api.h"\n'
    '#include "include/dart_native_api.h"\n'
    '#include "dartify.h"\n'
    '#include "$infilePath"\n');
}

/**
 * Outputs the wrapper for a synchronous dart extension.
 */
void syncWrapper(prototype) {
  writeln('${_wrapperProto(prototype)} {');
  enterBlock();
  writeln('Dart_EnterScope();');
  writeln('Dart_Handle error;');
  
  if (prototype.parameters != null) {
    for (int i=0; i<prototype.parameters.length; i++) {
      writeln(_paramAlloc(prototype.parameters[i], i));
    }
  }

  if (prototype.type != 'void') {
    write('${prototype.type} result =');
  }

  writeln('${prototype.id}(${_paramList(prototype.parameters)});');
  writeln(_retStmt(prototype.type, "result"));
  writeln('Dart_ExitScope();');
  exitBlock();
  writeln('}\n');
}

/**
 * Outputs the wrapper for a synchronous dart extension that uses a libgmp 
 * data structure as a return type.
 */
void syncGmpWrapper(prototype) {
  _ensureValidGmpPrototype(prototype);

  var id = prototype.id,
      rettype = prototype.parameters.first.type,
      retid = prototype.parameters.first.id;

  writeln('${_wrapperProto(prototype)} {');
  enterBlock();
  writeln('Dart_EnterScope();\n');
  writeln('Dart_Handle error;');
  writeln('$rettype $retid;');
  writeln('${_gmpInitializer(rettype)}($retid);');
  writeln('${_gmpInitializer(rettype)}(${_dartifyResultField(rettype)});');
  
  for (int i=1; i<prototype.parameters.length; i++) {
    writeln(_paramAlloc(prototype.parameters[i], i-1));
  }

  writeln('$id(${_paramList(prototype.parameters)});');
  writeln(_retStmt(rettype, retid));
  writeln('${_gmpDestructor(rettype)}($retid);');
  writeln('${_gmpDestructor(rettype)}(${_dartifyResultField(rettype)});');
  writeln('Dart_ExitScope();');
  exitBlock();
  writeln('}\n');
}

void nativeResolver(prototypes) {
  writeln('Dartify_ResolveName(');
  enterBlock();
  prototypes.forEach((p) =>
      writeln('if (!strcmp("${p.id}", cname)) return ${_wrapperId(p.id)};'));
  exitBlock();
  writeln(')\n');
}

void initializer(libname) {
  writeln('Dartify_InitializeExtension(${_initializerId(libname)})');
}
