import 'package:nerf_dart/parsers/ansi_c.dart';

void main() {
  var parser = new AnsiCGrammar();

  group("Terminals:", () {
    test("IDENTIFIER", () {
      List validIds = ["_", "f", "F", "_foo", "_Foo", "foo_Bar", "fooBar", "foo_barOne18"];
      List invalidIds = ["12", "1foo", "@wrap"];
      validIds.forEach((id) {
        var result = parser.IDENTIFIER.parse(id);
        expect(result.isSuccess, equals(true));
      });

      invalidIds.forEach((id) {
        var result = parser.IDENTIFIER.parse(id);
        expect(result.isFailure, equals(true));
      });
    });

    test("ANNOTATION", () {
      var result = parser.ANNOTATION.parse("//@dartify:async");
      expect(result.isSuccess, equals(true));      
      result = parser.ANNOTATION.parse("//@dartify:sync");
      expect(result.isSuccess, equals(true));      

      result = parser.ANNOTATION.parse("//just a comment");
      expect(result.isFailure, equals(true));
      result = parser.ANNOTATION.parse("//@dartify notquite");
      expect(result.isFailure, equals(true));
    });
  });

  group("Non-Terminals:", () {
    test("typeSpecifier", () {
      var result = parser.typeSpecifier.parse("void");
      expect(result.isSuccess, equals(true));      
      result = parser.typeSpecifier.parse("char");
      expect(result.isSuccess, equals(true));
      result = parser.typeSpecifier.parse("short");
      expect(result.isSuccess, equals(true));
      result = parser.typeSpecifier.parse("int");
      expect(result.isSuccess, equals(true));
      result = parser.typeSpecifier.parse("long");
      expect(result.isSuccess, equals(true));
      result = parser.typeSpecifier.parse("float");
      expect(result.isSuccess, equals(true));
      result = parser.typeSpecifier.parse("double");
      expect(result.isSuccess, equals(true));
      result = parser.typeSpecifier.parse("signed");
      expect(result.isSuccess, equals(true));
      result = parser.typeSpecifier.parse("unsigned");
      expect(result.isSuccess, equals(true));
      
      result = parser.typeSpecifier.parse("string");
      expect(result.isFailure, equals(true));
      result = parser.typeSpecifier.parse("boolean");
      expect(result.isFailure, equals(true));
      result = parser.typeSpecifier.parse("Integer");
      expect(result.isFailure, equals(true));
    });

    test("typeQualifer", () {
      var result = parser.typeQualifier.parse("const");
      expect(result.isSuccess, equals(true));      
      result = parser.typeQualifier.parse("restrict");
      expect(result.isSuccess, equals(true));
      result = parser.typeQualifier.parse("volatile");
      expect(result.isSuccess, equals(true));
      result = parser.typeQualifier.parse("atomic");
      expect(result.isSuccess, equals(true));
      
      result = parser.typeQualifier.parse("Constant");
      expect(result.isFailure, equals(true));
      result = parser.typeQualifier.parse("struct");
      expect(result.isFailure, equals(true));
      result = parser.typeQualifier.parse("final");
      expect(result.isFailure, equals(true));
    });

    test("storageClassSpecifier", () {
      var result = parser.storageClassSpecifier.parse("typedef");
      expect(result.isSuccess, equals(true));      
      result = parser.storageClassSpecifier.parse("extern");
      expect(result.isSuccess, equals(true));
      result = parser.storageClassSpecifier.parse("static");
      expect(result.isSuccess, equals(true));
      result = parser.storageClassSpecifier.parse("auto");
      expect(result.isSuccess, equals(true));
      result = parser.storageClassSpecifier.parse("register");
      
      result = parser.storageClassSpecifier.parse("constant");
      expect(result.isFailure, equals(true));
      result = parser.storageClassSpecifier.parse("struct");
      expect(result.isFailure, equals(true));
      result = parser.storageClassSpecifier.parse("final");
      expect(result.isFailure, equals(true));
    });

    test("declarationSpecifier", () {});

    test("declarationSpecifiers", () {
      var result = parser.declarationSpecifiers.parse("const int");
      expect(result.isSuccess, equals(true));
      result = parser.declarationSpecifiers.parse("volatile const char");
      expect(result.isSuccess, equals(true));
      result = parser.declarationSpecifiers.parse("atomic float");
      expect(result.isSuccess, equals(true));

      result = parser.declarationSpecifiers.parse("foo volatile const char");
      expect(result.isFailure, equals(true));
      result = parser.declarationSpecifiers.parse("bar char atomic float");
      expect(result.isFailure, equals(true));      
    });

    test("declarator", () {
      var result = parser.declarator.parse("*** foo(int);");
      expect(result.isSuccess, equals(true));
      result = parser.declarator.parse("foo(int);");
      expect(result.isSuccess, equals(true));
    });

    test("parameterDeclaration", () {
      List validPDs = ["int foobar", "const int _baz123", "volatile double _", "int"];
      List invalidPDs = ["foobar", "_const", "_"];
      validPDs.forEach((pd) {
        var result = parser.parameterDeclaration.parse(pd);
        expect(result.isSuccess, equals(true));
      });
      invalidPDs.forEach((pd) {
        var result = parser.parameterDeclaration.parse(pd);
        expect(result.isFailure, equals(true));
      });
    });

    test("parameterList", () {
      List validPLs = ["int foobar, const int _baz123", "volatile double _, volatile float x, float"];
      List invalidPLs = ["NOTATYPE const int", "\$ float _"];
      validPLs.forEach((pl) {
        var result = parser.parameterList.parse(pl);
        expect(result.isSuccess, equals(true));
      });
      invalidPLs.forEach((pl) {
        var result = parser.parameterList.parse(pl);
        expect(result.isFailure, equals(true));
      });
    });

    test("directDeclarator", () {
      List validDDs = [
        "foo()", "_foo()", "_()", "_l33t()", // IDENTIFIER ()
        "foo(int bar, int baz, const volatile int _l33t_S0_hc)" // IDENTIFIER ( parameterTypeList )
      ];
      List invalidDDs = [
        ")foobar", "\$", "1const int"
      ];
      validDDs.forEach((pl) {
        var result = parser.directDeclarator.parse(pl);
        expect(result.isSuccess, equals(true));
      });
      invalidDDs.forEach((pl) {
        var result = parser.directDeclarator.parse(pl);
        expect(result.isFailure, equals(true));
      });
    });

    test("functionProtoype", () {
      List validProtos = [
        "const int *foo(int bar, int baz);",
        "void *foo(int, char, void);",
        "int** const * foo(int *myint, const double mydoub);",
        "int foo(int x, ...);",
      ];
      validProtos.forEach((dec) {
        var result = parser.functionPrototype.parse(dec);
        expect(result.isSuccess, equals(true));
      });
    });
  });
}
