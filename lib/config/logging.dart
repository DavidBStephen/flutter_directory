import 'package:logger/logger.dart';

final memoryOutput = MemoryOutput();

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
  output: MultiOutput([ConsoleOutput(), memoryOutput]),
);
