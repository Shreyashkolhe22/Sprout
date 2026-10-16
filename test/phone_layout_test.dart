import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/notes/data/attachment_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

/// Regression test for layout overflows on real phone sizes with the
/// keyboard open. Any RenderFlex overflow fails the test.
void main() {
  for (final size in const [Size(360, 640), Size(411, 891)]) {
    testWidgets('phone ${size.width}x${size.height} layout with keyboard open',
        (tester) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final harness = TestHarness();
      harness.picker.images = [
        for (var i = 0; i < 4; i++)
          PickedAttachment(name: 'photo$i.png', path: '/x/photo$i.png'),
      ];
      harness.picker.pdfs = [
        const PickedAttachment(
          name: 'a-really-long-document-name-for-layout-testing.pdf',
          path: '/x/doc.pdf',
        ),
      ];
      await tester.pumpWidget(harness.build());

      // walk every onboarding page so each is laid out at this size
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      // keyboard up on the name page (~300 logical px)
      tester.view.viewInsets = FakeViewPadding(bottom: 300 * 3);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Sam');
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();

      await tester.tap(find.text("Let's grow"));
      await tester.pumpAndSettle();
      expect(find.text('Hey, Sam!'), findsOneWidget);

      // empty state, then add a habit with the keyboard up
      await tester.tap(find.byKey(const Key('nav-add')));
      await tester.pumpAndSettle();
      tester.view.viewInsets = FakeViewPadding(bottom: 300 * 3);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Meditate');
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // focus screen
      await tester.tap(find.text('Meditate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Mark as done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // profile sheet
      await tester.tap(find.byKey(const Key('profile-button')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // notes: empty state, editor with keyboard and many attachments
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-add')));
      await tester.pumpAndSettle();
      tester.view.viewInsets = FakeViewPadding(bottom: 300 * 3);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('note-title')), 'Trip');
      await tester.enterText(find.byKey(const Key('note-body')), 'Pack bags\n' * 20);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();

      for (final option in const ['attach-image', 'attach-pdf']) {
        await tester.tap(find.byKey(const Key('attach-button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key(option)));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('save-note'))); // read mode
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('note-back')));
      await tester.pumpAndSettle();
      expect(find.text('Trip'), findsOneWidget);

      // stats
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();
      expect(find.text('Your week'), findsOneWidget);
    });
  }
}
