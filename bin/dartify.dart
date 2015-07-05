library dartify;

import 'dart:io';

import 'package:args/args.dart';

import 'package:dartify/parser.dart';
import 'package:dartify/generator.dart' as gen;

final argparser = new ArgParser();

/// Prints the program's usage and exits
void usage() {
  stderr.writeln('usage: dartify [options] C-source-file');
  stderr.writeln(argparser.getUsage());
  exit(0);
}

/// Parse command line arguments and handle any callbacks
ArgResults parseArgs(List args) {
  argparser.addFlag('help', 
    abbr: 'h',
    help: 'Display this help and exit',
    negatable: false,
    callback: (value) { if (value) usage(); });
  
  argparser.addFlag('type-checks',
    abbr: 't',
    negatable: false,
    help: 'Generate type-checks and exceptions for parameter types');

  argparser.addFlag('verbose', 
    abbr: 'v', 
    negatable: false,
    help: 'Enable verbose output');

  argparser.addFlag('version',
    help: 'Display version information',
    negatable: false);

  return argparser.parse(args);
}

void main(List<String> args) {
  var settings,
      syncExports,
      syncGmpExports,
      infile,
      source,
      cparser,
      exports;
  
  settings = parseArgs(args);

  if (settings.rest != null && settings.rest.length == 1) {
    infile = new File(settings.rest[0]);
    if (!infile.existsSync()) {
      throw new FileSystemException('cannot open ${infile.absolute}');
    }
    source = infile.readAsStringSync();
  } else { usage(); }

  cparser = new AnsiCParser();
  exports = cparser.parse(source);
  syncExports = [];
  syncGmpExports = [];

  exports.forEach((exp) {
    var annotation = exp.annotation,
        prototype = exp.prototype;

    switch(annotation) {
      case 'sync':
        syncExports.add(prototype); 
        break;
      case 'syncgmp':
        syncGmpExports.add(prototype);
        break;
      default:
        throw new UnsupportedError('unrecognized annotation "$annotation"');
     }
  });

  var wrappers = "",
      wrapper,
      wrapperSource;

  syncExports.forEach((exp) {
    wrapper = gen.synchronousFunctionWrapper(exp);
    wrappers = "$wrappers\n$wrapper";
  });

  syncGmpExports.forEach((exp) {
    wrapper = gen.synchronousGmpFunctionWrapper(exp);
    wrappers = "$wrappers\n$wrapper";
  });

  var allExports = exports.map((exp) => exp.prototype).toList();

  wrapperSource =
    '#include <string.h>\n'
    '#include "include/dart_api.h"\n'
    '#include "include/dart_native_api.h"\n'
    '#include "dartify.h"\n'
    '#include "${infile.path}"\n'
    '$wrappers\n'
    '${gen.nativeResolver(allExports)}\n'
    '${gen.initializer()}\n';

  stdout.write(wrapperSource);
}
