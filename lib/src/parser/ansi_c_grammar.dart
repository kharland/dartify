part of dartify.parser;

/// A class for parsing ANSI C grammar. This class has a few made-up 
/// productions to remove recursion and speed up prototyping. 
@TODO("re-implement as a proper subclass of GrammarParser")
class _AnsiCGrammar {
  Parser token(dynamic input) {
    if (input is String) {
      input = input.length == 1 ? char(input) : string(input);
    }
    if (input is! String && input is! Parser) {
      throw new StateError('Invalid token parser: $input');
    }
    return input.flatten().trim();
  }

  get LETTER => letter();
  get WORD => word();

  // C Tokens
  get UNDERSCORE => token('_');
  get COLON => token(':');
  get COMMA => token(',');
  get CONST => token("const");
  get RESTRICT => token("restrict");
  get VOLATILE => token("volatile");
  get ATOMIC => token("atomic");
  get VOID => token("void");
  get CHAR => token("char");
  get BOOL => token("bool"); // technically not C
  get SHORT => token("short");
  get INT => token("int");
  get UINT => token("uint");
  get INT64_T => token("int64_t");
  get UINT64_T => token("uint64_t");
  get MPZ_T => token("mpz_t");
  get LONG => token("long");
  get FLOAT => token("float");
  get DOUBLE => token("double");
  get SIGNED => token("signed");
  get UNSIGNED => token("unsigned");
  get OPARENTHESIS => token('(');
  get CPARENTHESIS => token(')');
  get TYPEDEF => token("typedef");
  get REGISTER => token("register");
  get AUTO => token("auto");
  get STATIC => token("static");
  get EXTERN => token("extern");
  get ELLIPSIS => token("...");
  get IDENTIFIER_START => LETTER | UNDERSCORE;
  get IDENTIFIER_PART => WORD | UNDERSCORE;
  get IDENTIFIER => token(IDENTIFIER_START & IDENTIFIER_PART.star());

  // helpful tokens
  get ANNOTATION => token(string("//@") & LETTER.plus() & COLON & LETTER.plus());

  // MP
  get typeSpecifier => 
      VOID
    | CHAR
    | BOOL
    | SHORT
    | INT
    | UINT
    | INT64_T
    | UINT64_T
    | MPZ_T
    | LONG
    | FLOAT
    | DOUBLE
    | SIGNED
    | UNSIGNED;

  get typeQualifier =>
      CONST
    | RESTRICT
    | VOLATILE
    | ATOMIC;

  get typeQualifierList => typeQualifier.plus();

  get storageClassSpecifier =>
      TYPEDEF
    | EXTERN
    | STATIC
    | AUTO
    | REGISTER;

  /// This is an imaginary grammar production to remove the indirect recursion
  /// from the parameter -> declarator production
  /// MP
  get parameterDeclarator => pointer.optional() & IDENTIFIER;

  // MP
  get parameterDeclaration => declarationSpecifiers & parameterDeclarator.optional();

  get parameterList => parameterDeclaration & (COMMA & parameterDeclaration).star();

  get parameterTypeList => parameterList & (COMMA & ELLIPSIS).optional();
   
  // MP
  get directDeclarator =>
      IDENTIFIER & char('(') & parameterTypeList.optional() & char(')');

  /// This is an imaginary grammar production to remove recursion from the
  /// pointer production.
  get pointerStart => char('*') & typeQualifierList.optional();
  
  get pointer => pointerStart.plus();

  get declarator => pointer.optional() & directDeclarator;

  /// This is an imaginary grammar production to remove recursion from the
  /// declarationSpecifiers production.
  get declarationSpecifier =>
      typeSpecifier
    | typeQualifier
    | storageClassSpecifier;

  get declarationSpecifiers => declarationSpecifier.plus();

  /// This is an imaginary grammar production.
  /// This is the production we use to match against and extract all 
  /// function declarations from a C source file. It is a function definition
  /// without the trailing compound statement;
  /// MP
  get functionPrototype => declarationSpecifiers.optional() & declarator;

  /// This is an imaginary grammar production. It is also the start production 
  /// for matching all function prototypes that are marked with an annotation.
  get dartifyExport => ANNOTATION & functionPrototype;
}

