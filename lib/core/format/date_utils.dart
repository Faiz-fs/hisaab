// Date utility functions for Hisaab.
// All helpers are pure functions; no state.

/// Returns [DateTime] at midnight (00:00:00) for [date].
DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// Returns the total number of days in [date]'s month.
int daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

/// Returns the number of days remaining in [date]'s month (inclusive of [date]).
int daysLeftInMonth(DateTime date) => daysInMonth(date) - date.day + 1;

/// Returns true if [a] and [b] fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
