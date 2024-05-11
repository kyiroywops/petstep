import 'package:amclub/screens/widgets/progress_bar_home.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [
    Task(emoji: "📝", name: "Registrar objetivos diarios"),
    Task(emoji: "🏋️", name: "Actividad física"),
    Task(emoji: "🙏", name: "Tiempo de reflexión y gratitud"),
    Task(emoji: "📚", name: "Lectura diaria"),
  ];

  int get completedTasksCount => tasks.where((task) => task.isDone).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: SingleChildScrollView(  // Permite hacer scroll en todo el contenido
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
                    
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
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
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This is today your missions.',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'HindMurai', color: Colors.grey.shade300),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$completedTasksCount of ${tasks.length} completed',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'HindMurai'),
                      ),
                      SizedBox(height: 10),
                      CustomProgressIndicator(
                        value: completedTasksCount / tasks.length,
                        height: 20,
                        backgroundColor: Colors.grey.shade400,
                        progressColor: Colors.greenAccent.shade400,
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,  // Importante para ListView en SingleChildScrollView
                        physics: NeverScrollableScrollPhysics(),  // Desactiva el scrolling de ListView
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    tasks[index].emoji,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    tasks[index].name,
                                    style: TextStyle(
                                      fontFamily: 'HindMurai',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.grey.shade300,
                                      decoration: tasks[index].isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                      
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    tasks[index].isDone ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.solidCircle,
                                    color: tasks[index].isDone ? Colors.greenAccent.shade400 : Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      tasks[index].isDone = !tasks[index].isDone;
                                    });
                                  },
                                ),
                              ],
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
