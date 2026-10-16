import 'package:flutter/material.dart';

/// Icons a habit can use. Habits store an *index* into this list (not a raw
/// code point) so saved data stays valid and icon tree-shaking keeps working.
abstract final class HabitIcons {
  static const all = <IconData>[
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.water_drop_rounded,
    Icons.self_improvement_rounded,
    Icons.bedtime_rounded,
    Icons.directions_walk_rounded,
    Icons.code_rounded,
    Icons.savings_rounded,
    Icons.restaurant_rounded,
    Icons.edit_note_rounded,
    Icons.music_note_rounded,
    Icons.cleaning_services_rounded,
  ];

  static IconData at(int index) =>
      (index >= 0 && index < all.length) ? all[index] : all.first;
}
