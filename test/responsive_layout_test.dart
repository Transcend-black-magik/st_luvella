import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luvella/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in const [
    Size(1280, 900),
    Size(1024, 768),
    Size(768, 1024),
  ]) {
    testWidgets('homepage has no layout exception at ${size.width.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: LuvellaApp()));
      await tester.pumpAndSettle();

      expect(find.text('FORM\nFOLLOWS\nFEELING'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
