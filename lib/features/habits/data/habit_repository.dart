import '../domain/habit.dart';

/// Where one user's habits are stored. Swap the implementation (local
/// storage, SQLite, a REST API...) without touching the UI or controller.
abstract interface class HabitRepository {
  Future<List<Habit>> load();
  Future<void> save(List<Habit> habits);
}

/// Builds the repository for a signed-in user.
typedef HabitRepositoryFactory = HabitRepository Function(String userName);

/// Keeps habits in memory only. Used by tests and previews.
class InMemoryHabitRepository implements HabitRepository {
  InMemoryHabitRepository({List<Habit>? seed}) : _habits = [...?seed];

  List<Habit> _habits;

  @override
  Future<List<Habit>> load() async => List.of(_habits);

  @override
  Future<void> save(List<Habit> habits) async {
    _habits = List.of(habits);
  }
}
