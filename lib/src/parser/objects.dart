part of dartify.parser;

class Parameter {
  final String type;
  final String id;
  
  const Parameter(this.type, this.id);
}

class DeclarationSpecifiers {
  final List specifiers;

  const DeclarationSpecifiers(this.specifiers);
}

class FunctionPrototype {
  final String type;
  final String id;
  final List<Parameter> parameters;
  
  const FunctionPrototype(this.type, this.id, this.parameters);
}

class DartifyExport {
  final String annotation;
  final FunctionPrototype prototype;
  
  const DartifyExport(this.annotation, this.prototype);
}
