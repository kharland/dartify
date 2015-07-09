library dartify;

import 'dart:io';
import 'package:args/args.dart';
import 'package:dartify/parser.dart';
import 'package:dartify/generator.dart' as gen;

final argparser = new ArgParser();
  
String extractFilename(File infile) =>
  infile.path.split(Platform.pathSeparator).last.split('.').first;

bool inputFileProvided(ArgResults settings) =>
  settings.rest != null && settings.rest.length == 1;

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
      syncProtos,
      asyncProtos,
      syncGmpProtos,
      asyncGmpProtos,
      infile,
      extname,
      source,
      cparser,
      exports,
      prototypes;
  
  settings = parseArgs(args);
  if (inputFileProvided(settings)) {
    infile = new File(settings.rest[0]);
    extname = extractFilename(infile);
    if (!infile.existsSync()) {
      throw new FileSystemException('cannot open ${infile.absolute}');
    }
    source = infile.readAsStringSync();
  } else { 
    usage(); 
  }

  cparser = new AnsiCParser();
  exports = cparser.parse(source);
  prototypes = exports.map((exp) => exp.prototype).toList();
  syncProtos = [];
  asyncProtos = [];
  syncGmpProtos = [];
  asyncGmpProtos = [];

  exports.forEach((exp) {
    switch (exp.annotation) {
      case 'sync':
        syncProtos.add(exp.prototype);
        break;
      case 'async': 
       asyncProtos.add(exp.prototype); 
       break;
      case 'syncgmp':
        syncGmpProtos.add(exp.prototype);
        break;
      case 'asyncgmp': 
       asyncGmpProtos.add(exp.prototype); 
       break;
      default:
        throw new UnsupportedError('Invalid annotation "$exp.annotation"');
    }
  });

  gen.extensionHeader(infile.path);
  gen.writeln();
  syncProtos.forEach((exp) => gen.syncWrapper(exp));
  // asyncProtos.forEach((exp) => gen.asyncWrapper(exp));
  syncGmpProtos.forEach((exp) => gen.syncGmpWrapper(exp));
  // asyncGmpProtos.forEach((exp) => gen.asyncGmpWrapper(exp));
  gen.nativeResolver(prototypes);
  gen.initializer(extname);
}
