import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('SelectFriendsDialogModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
