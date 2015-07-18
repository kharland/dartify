part of dartify.parser;

// Any grammar construct labeled "IMAG" is a made up recursion.
//
// Any grammar construct labeled "IMAG : PRODUCTION" was crearted to 
// eliminate recursion from PRODUCTION.
// 
// Any grammar construct labled "MP" is not fully implemented and is missing
// at least one of its productions according to the ANSI C grammar spec.

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
  get SIZE_T => token("size_t");
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

  // IMAG
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
    | SIZE_T
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

  /// MP
  /// IMAG : declarator
  get parameterDeclarator => pointer.optional() & IDENTIFIER;

  // MP
  get parameterDeclaration => declarationSpecifiers & parameterDeclarator.optional();

  get parameterList => parameterDeclaration & (COMMA & parameterDeclaration).star();

  get parameterTypeList => parameterList & (COMMA & ELLIPSIS).optional();
   
  // MP
  get directDeclarator =>
      IDENTIFIER & char('(') & parameterTypeList.optional() & char(')');

  /// IMAG : pointer
  get pointerStart => char('*') & typeQualifierList.optional();
  
  get pointer => pointerStart.plus();

  get declarator => pointer.optional() & directDeclarator;

  /// IMAG : declarationSpecifiers production.
  get declarationSpecifier =>
      typeSpecifier
    | typeQualifier
    | storageClassSpecifier;

  get declarationSpecifiers => declarationSpecifier.plus();

  /// MP
  /// IMAG
  get functionPrototype => declarationSpecifiers.optional() & declarator;

  /// IMAG
  get dartifyExport => ANNOTATION & functionPrototype;
}

