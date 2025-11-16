import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home screen no longer depends on FeatureIcon', () {
    final file = File('lib/screens/home_screen.dart');
    final contents = file.readAsStringSync();
    expect(contents.contains('FeatureIcon'), isFalse);
  });
}
