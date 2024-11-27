import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('InsightGeneratorServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
