import 'package:flutter_application_1/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatFileSize', () {
    test('bytes, kilobytes and megabytes', () {
      expect(formatFileSize(512), '512 B');
      expect(formatFileSize(2048), '2 KB');
      expect(formatFileSize(5 * 1024 * 1024 + 300 * 1024), '5.3 MB');
      expect(formatFileSize(25 * 1024 * 1024), '25 MB');
    });
  });

  group('formatNoteDate', () {
    final now = DateTime(2026, 10, 14, 15, 0);

    test('today shows the time', () {
      expect(formatNoteDate(DateTime(2026, 10, 14, 9, 5), now), 'Today, 09:05');
    });

    test('yesterday', () {
      expect(formatNoteDate(DateTime(2026, 10, 13, 23, 59), now), 'Yesterday');
    });

    test('earlier this year omits the year', () {
      expect(formatNoteDate(DateTime(2026, 3, 2), now), '2 Mar');
    });

    test('other years include it', () {
      expect(formatNoteDate(DateTime(2025, 12, 31), now), '31 Dec 2025');
    });
  });
}
