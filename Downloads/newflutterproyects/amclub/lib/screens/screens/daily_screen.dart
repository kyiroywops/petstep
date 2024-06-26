import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DailyScreen extends StatefulWidget {
  DailyScreen({Key? key}) : super(key: key);

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  List<Task> tasks = [
    Task(name: "Milk"),
    Task(name: "Dozen eggs"),
    Task(name: "Cabbage"),
    Task(name: "Dark chocolate"),
    Task(name: "Lemonade")
  ];
  TextEditingController textController = TextEditingController();

  void addTask() {
    if (textController.text.isNotEmpty) {
      setState(() {
        tasks.add(Task(name: textController.text));
        textController.clear();
      });
    }
  }

  void toggleTaskDone(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      'Daily Tasks',
                      style: TextStyle(fontSize: 20, color: Colors.grey.shade300, fontFamily: 'HindMurai', fontWeight: FontWeight.w800),
                    ),
                    Icon(
                      FontAwesomeIcons.fire,
                      color: Colors.redAccent.shade100,
                      size: 19,
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tasks.length + 1, // Plus one for the "Add Subtask" button
                itemBuilder: (context, index) {
                  if (index == tasks.length) {
                    // The item for adding new tasks
                    return ListTile(
                      title: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.grey.shade400),
                            onPressed: addTask,
                          ),
                          Expanded(
                            child: TextField(
                              style: TextStyle(color: Colors.grey.shade100, fontSize: 13, fontFamily: 'HindMurai', fontWeight: FontWeight.w800),
                              controller: textController,
                              decoration: InputDecoration(
                                hintText: "ADD SUBSTASK",
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => addTask(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListTile(
                    leading: IconButton(
                      icon: Icon(
                        tasks[index].isDone ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.solidCircle,
                        color: tasks[index].isDone ? Colors.greenAccent.shade400 : Colors.grey.shade400,
                      ),
                      onPressed: () => toggleTaskDone(index),
                    ),
                    title: Text(tasks[index].name, style: TextStyle(
                      color: Colors.grey.shade100, fontSize: 16, fontFamily: 'HindMurai', fontWeight: FontWeight.w800
                    )),
                    trailing: Icon(FontAwesomeIcons.bars, color: Colors.grey.shade400),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  String name;
  bool isDone;

  Task({required this.name, this.isDone = false});
}
