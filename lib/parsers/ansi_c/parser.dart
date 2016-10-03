import 'package:petitparser/petitparser.dart';

/// An ANSI-C grammar parser.
///
/// This parser only accepts function defintions, because we do not export other
/// language constructs in native extensions.
class AnsiCGrammar extends GrammarParser {
  AnsiCGrammar() : super(const AnsiCGrammarDefinition());
}

/// An ANSI-C grammar definition 
///
/// This class provides certain transformations to facilitate working with 
/// parsed text such as tokenization of identifers and abstractions of complex
/// grammar constructs such as function definitions and parameter declarations.
class AnsiCGrammarDefinition extends _AnsiCGrammarDefinition {
  // TODO(kharland): Support the set function_definition production.
  // TODO(kharland): Add more transformations.
  const AnsiCGrammarDefinition() : super();

  @override
  Parser identifier() => super.identifier().flatten().trim();
}

/// An implementation of a subset of the ANSI C Grammar.
class _AnsiCGrammarDefinition extends GrammarDefinition {
  static Parser _token(String input) => string(input).flatten().trim();
  
  const _AnsiCGrammarDefinition();

  @override
  Parser start() => ref(functionDefinition).end();

  Parser functionDefinition() =>
      ref(declarationSpecifiers).optional() & ref(declarator);

  Parser declarationSpecifiers() =>
      (ref(typeSpecifier) | ref(typeQualifier) | ref(storageClassSpecifier))
          .plus();

  Parser declarator() => ref(pointer).optional() & ref(directDeclarator);

  Parser directDeclarator() =>
      ref(identifier) &
      ref(LPAREN) &
      ref(parameterTypeList).optional() &
      ref(RPAREN);

  Parser pointer() =>
      (ref(ASTERISK) & ref(typeQualifierList).optional()).plus();

  Parser identifier() =>
      (ref(letter) | ref(UNDERSCORE)) & (ref(word) | ref(UNDERSCORE)).star();

  Parser parameterTypeList() =>
      ref(parameterList) & (ref(COMMA) & ref(ELLIPSIS)).optional();

  Parser parameterList() =>
      ref(parameterDeclaration) & (ref(COMMA) & ref(parameterList)).optional();

  Parser parameterDeclaration() =>
      ref(declarationSpecifiers) & ref(declarator).optional();

  Parser typeSpecifier() =>
      ref(VOID) |
      ref(CHAR) |
      ref(SHORT) |
      ref(INT) |
      ref(UINT) |
      ref(INT64_T) |
      ref(UINT64_T) |
      ref(MPZ_T) |
      ref(SIZE_T) |
      ref(LONG) |
      ref(FLOAT) |
      ref(DOUBLE) |
      ref(SIGNED) |
      ref(UNSIGNED);

  Parser typeQualifier() =>
      ref(CONST) | ref(RESTRICT) | ref(VOLATILE) | ref(ATOMIC);

  Parser typeQualifierList() => ref(typeQualifier).plus();

  Parser storageClassSpecifier() =>
      ref(TYPEDEF) | ref(EXTERN) | ref(STATIC) | ref(AUTO) | ref(REGISTER);

  Parser ELLIPSIS() => _token("...");
  Parser UNDERSCORE() => _token('_');
  Parser ASTERISK() => _token('*');
  Parser COLON() => _token(':');
  Parser COMMA() => _token(',');
  Parser LPAREN() => _token('(');
  Parser RPAREN() => _token(')');
  Parser CONST() => _token("const");
  Parser RESTRICT() => _token("restrict");
  Parser VOLATILE() => _token("volatile");
  Parser ATOMIC() => _token("atomic");
  Parser VOID() => _token("void");
  Parser CHAR() => _token("char");
  Parser SHORT() => _token("short");
  Parser INT() => _token("int");
  Parser UINT() => _token("uint");
  Parser INT64_T() => _token("int64_t");
  Parser UINT64_T() => _token("uint64_t");
  Parser MPZ_T() => _token("mpz_t");
  Parser SIZE_T() => _token("size_t");
  Parser LONG() => _token("long");
  Parser FLOAT() => _token("float");
  Parser DOUBLE() => _token("double");
  Parser SIGNED() => _token("signed");
  Parser UNSIGNED() => _token("unsigned");
  Parser TYPEDEF() => _token("typedef");
  Parser REGISTER() => _token("register");
  Parser AUTO() => _token("auto");
  Parser STATIC() => _token("static");
  Parser EXTERN() => _token("extern");
}
