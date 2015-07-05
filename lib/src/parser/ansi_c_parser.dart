part of dartify.parser;

/// Singleton class for parsing C-source text based on the 1985 ANSI C grammar 
/// published by Jeff Lee:
/// http://www.lysator.liu.se/(nobg)/c/ANSI-C-grammar-y.html#declaration
abstract class AnsiCParser {
  /// factory constructor to return an instance of the default implementation
  factory AnsiCParser() => new _AnsiCParser();

  List parse(String source);
}
