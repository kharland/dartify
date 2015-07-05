part of dartify.generator;

class DartifyException implements Exception {
  final String message;
  final String culprit;

  @override
  toString() => '$runtimeType: ($culprit) $message';

  const DartifyException(this.message, this.culprit);
}

class ReturnTypeException extends DartifyException {
  ReturnTypeException(String message, String culprit) : super (message, culprit);
}

class ParameterException extends DartifyException {
  ParameterException(String message, String culprit) : super (message, culprit);
}
