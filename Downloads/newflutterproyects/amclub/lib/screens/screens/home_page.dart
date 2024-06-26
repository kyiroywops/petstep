import 'dart:async';
import 'package:amclub/screens/providers/dailytask_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:amclub/screens/widgets/progress_bar_home.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  String timeLeft = '';

  Future<void> loadDailyTasks(WidgetRef ref) async {
    final userId = 'currentUserId'; // Reemplaza con la lógica para obtener el ID del usuario actual
    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('dailyTasks')
        .get();

    if (tasksSnapshot.docs.isNotEmpty) {
      final tasks = tasksSnapshot.docs.map((doc) {
        return DailyTask(
          id: doc.id,
          taskName: doc['taskName'],
          emoji: doc['emoji'],
          isCompleted: doc['isCompleted'],
          progress: doc['progress'],
        );
      }).toList();

      ref.read(dailyTasksProvider.notifier).loadTasks(tasks);
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        timeLeft = calculateTimeLeft();
      });
    });
    timeLeft = calculateTimeLeft(); // Initial calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDailyTasks(ref); // Load tasks when the screen initializes
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String calculateTimeLeft() {
    DateTime now = DateTime.now();
    DateTime targetTime = DateTime(now.year, now.month, now.day, 7);
    if (now.hour >= 7) {
      targetTime = targetTime.add(Duration(days: 1));
    }
    Duration difference = targetTime.difference(now);
    return '${difference.inHours.toString().padLeft(2, '0')}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(dailyTasksProvider);
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final totalTasks = tasks.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 50,
                    ),
                    Row(
                      children: [
                        Text(
                          '$completedTasks',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade300,
                            fontFamily: 'HindMurai',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            FontAwesomeIcons.fire,
                            color: Colors.redAccent.shade100,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This is today your missions.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'HindMurai',
                          color: Colors.grey.shade300,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$completedTasks of $totalTasks completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontFamily: 'HindMurai',
                        ),
                      ),
                      SizedBox(height: 10),
                      CustomProgressIndicator(
                        value: completedTasks / totalTasks,
                        height: 20,
                        backgroundColor: Colors.grey.shade400,
                        progressColor: Colors.greenAccent.shade400,
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            timeLeft,
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.grey.shade300,
                              fontFamily: 'HindMurai',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              '  hours left',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade300,
                                fontFamily: 'HindMurai',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return GestureDetector(
                            onTap: () {
                              if (ref.read(dailyTasksProvider.notifier).isTaskAvailable(task.taskName)) {
                                if (task.taskName == "Drink water") {
                                  context.go('/drink');
                                }
                                // Maneja otras navegaciones aquí
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                                    child: Text(
                                      task.emoji,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Text(
                                        task.taskName,
                                        style: TextStyle(
                                          fontFamily: 'HindMurai',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.grey.shade300,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          decorationColor: Colors.grey.shade300,
                                          decorationStyle: TextDecorationStyle.solid,
                                          decorationThickness: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      task.isCompleted
                                          ? FontAwesomeIcons.solidCircleCheck
                                          : FontAwesomeIcons.solidCircle,
                                      color: task.isCompleted
                                          ? Colors.greenAccent.shade400
                                          : Colors.black,
                                    ),
                                    onPressed: () {
                                      ref.read(dailyTasksProvider.notifier).updateTask(task.id, !task.isCompleted, task.progress);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  String emoji;
  String name;
  bool isDone = false;

  Task({required this.emoji, required this.name});
}
