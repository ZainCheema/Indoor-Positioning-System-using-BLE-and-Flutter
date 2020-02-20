import 'dart:typed_data';
import 'dart:math';

final _random = new Random();

// Used in main.dart
int randomNumber(int min, int max) => min + _random.nextInt(max - min);

// Used in beacon_tools.dart
int byteToInt8(int b) =>
    new Uint8List.fromList([b]).buffer.asByteData().getInt8(0);

int twoByteToInt16(int v1, int v2) =>
    new Uint8List.fromList([v1, v2]).buffer.asByteData().getUint16(0);

String byteListToHexString(List<int> bytes) => bytes
    .map((i) => i.toRadixString(16).padLeft(2, '0'))
    .reduce((a, b) => (a + b));
