import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/illustration_card.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('first run: onboarding, empty app, add and tick a real habit',
      (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(TestHarness().build());

    expect(find.text('Stuck on\nthe couch?'), findsOneWidget);
    await finishOnboarding(tester, 'Sam');

    // starts with no habits at all
    expect(find.text('Hey, Sam!'), findsOneWidget);
    expect(find.text('Nothing planted yet'), findsOneWidget);
    expect(find.byType(IllustrationCard), findsWidgets);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('Add your first habit to get started.'), findsOneWidget);

    await addHabit(tester, 'Meditate');
    expect(find.text('Meditate'), findsOneWidget);
    expect(find.text('Nothing planted yet'), findsNothing);
    expect(find.text('0/1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('check-Meditate')));
    await tester.pump();
    expect(find.text('1/1'), findsOneWidget);
    expect(find.text('All done. You absolute legend!'), findsOneWidget);
  });

  testWidgets('empty name field shows an error and does not add a habit',
      (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(TestHarness(signedInAs: 'Sam').build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add my first habit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Give your habit a name'), findsOneWidget);
  });

  testWidgets('focus screen marks the habit done', (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(TestHarness().build());
    await finishOnboarding(tester, 'Sam');
    await addHabit(tester, 'Walk');

    await tester.tap(find.text('Walk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Mark as done'), findsOneWidget);
    await tester.tap(find.text('Mark as done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('logout returns to onboarding and the same name gets its habits back',
      (tester) async {
    tallScreen(tester);
    final harness = TestHarness();
    await tester.pumpWidget(harness.build());
    await finishOnboarding(tester, 'Sam');
    await addHabit(tester, 'Read');
    await tester.tap(find.byKey(const Key('check-Read')));
    await tester.pump();

    // log out from the profile sheet (header logo button)
    await tester.tap(find.byKey(const Key('profile-button')));
    await tester.pumpAndSettle();
    expect(find.text('Log out'), findsOneWidget);
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(harness.session.userName, isNull);
    expect(find.text('Stuck on\nthe couch?'), findsOneWidget);

    // a different person starts clean
    await finishOnboarding(tester, 'Alex');
    expect(find.text('Hey, Alex!'), findsOneWidget);
    expect(find.text('Read'), findsNothing);
    expect(find.text('Nothing planted yet'), findsOneWidget);

    // ...and Sam gets their habit (and tick) back
    await tester.tap(find.text('Profile')); // bottom-bar profile item
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await finishOnboarding(tester, 'sam');
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('a saved session skips onboarding', (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(TestHarness(signedInAs: 'Sam').build());
    await tester.pumpAndSettle();

    expect(find.text('Hey, Sam!'), findsOneWidget);
    expect(find.text('Stuck on\nthe couch?'), findsNothing);
  });

  testWidgets('stats tab shows the empty state, then real numbers',
      (tester) async {
    tallScreen(tester);
    await tester.pumpWidget(TestHarness(signedInAs: 'Sam').build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Your week'), findsOneWidget);
    expect(find.textContaining('Nothing to chart yet'), findsOneWidget);

    await addHabit(tester, 'Stretch');
    expect(find.text('By habit'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget); // 0 done of 1 available day
  });
}
