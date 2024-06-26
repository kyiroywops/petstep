import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyTask {
  final String id;
  final String taskName;
  final String emoji;
  final bool isCompleted;
  final int progress;

  DailyTask({
    required this.id,
    required this.taskName,
    required this.emoji,
    required this.isCompleted,
    required this.progress,
  });

  DailyTask copyWith({
    String? id,
    String? taskName,
    String? emoji,
    bool? isCompleted,
    int? progress,
  }) {
    return DailyTask(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      emoji: emoji ?? this.emoji,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }
}

class DailyTasksNotifier extends StateNotifier<List<DailyTask>> {
  DailyTasksNotifier() : super([]) {
    _loadInitialTasks();
  }

  void _loadInitialTasks() async {
    // Cargar tareas iniciales
    state = [
      DailyTask(id: '1', taskName: 'Record daily goals', emoji: '📝', isCompleted: false, progress: 0),
      DailyTask(id: '2', taskName: 'Physical activity', emoji: '🏋️', isCompleted: false, progress: 0),
      DailyTask(id: '3', taskName: 'Meditation', emoji: '🙏', isCompleted: false, progress: 0),
      DailyTask(id: '4', taskName: 'Drink water', emoji: '💧', isCompleted: false, progress: 0),
      DailyTask(id: '5', taskName: 'Daily reading', emoji: '📚', isCompleted: false, progress: 0),
    ];

    await _checkAndResetTasks();
  }

  Future<void> _checkAndResetTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('lastUpdate') ?? '';

    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';

    if (lastUpdate != today) {
      // Reiniciar las tareas
      state = [
        for (final task in state)
          task.copyWith(isCompleted: false, progress: 0)
      ];
      prefs.setString('lastUpdate', today);
    }
  }

  void loadTasks(List<DailyTask> tasks) {
    state = tasks;
  }

  void updateTask(String id, bool isCompleted, int progress) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isCompleted: isCompleted, progress: progress)
        else
          task,
    ];
  }

  bool isTaskAvailable(String taskName) {
    final now = DateTime.now();
    if (taskName == 'Record daily goals') {
      return true;
    }
    return now.hour >= 5 && now.hour < 7;
  }
}

final dailyTasksProvider = StateNotifierProvider<DailyTasksNotifier, List<DailyTask>>((ref) {
  return DailyTasksNotifier();
});
