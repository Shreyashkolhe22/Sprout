const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Strips the time component.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Calendar-day arithmetic that is safe across DST changes.
DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

/// Stable `yyyy-MM-dd` key used to store completions.
String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
