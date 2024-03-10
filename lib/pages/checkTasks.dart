import 'dart:io';
import 'package:flutter_todo/logic/localNotifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/logic/Task.dart';
import 'package:flutter_todo/logic/databaseHelper.dart';
import 'package:flutter_todo/pages/addTask.dart';

class CheckTasks extends StatefulWidget {
  DateTime? currentDate;

  CheckTasks({super.key, required this.currentDate});

  @override
  State<CheckTasks> createState() => _CheckTasksState();
}


class _CheckTasksState extends State<CheckTasks> {
  List<Task> todoList = [];
  DateTime? _currentDate;

  Future<void> updateTodoList(DateTime date) async {
    List<Map<String, dynamic>> tasksMap = await DatabaseHelper().getTasksForDay(date);
    List<Task> tasks = tasksMap.map((taskMap) => Task.fromMap(taskMap)).toList();

    tasks.sort((a, b) {
      int hourComparison = a.time!.hour - b.time!.hour;
      if (hourComparison != 0) {
        return hourComparison;
      }
      return a.time!.minute - b.time!.minute;
    });

    setState(() {
      todoList = tasks;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentDate = widget.currentDate;
    updateTodoList(_currentDate!);
  }

  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text("Кількість справ: ${todoList.length}"),
        centerTitle: true
      ),
      body: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onLongPressStart: (LongPressStartDetails details){
              _tapPosition = details.globalPosition;
            },
            onLongPress: () {
              showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(_tapPosition!.dx, _tapPosition!.dy, 0, 0),
                  items: [
                    PopupMenuItem(
                      child: Text("Редагувати"),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Text("Видалити"),
                      value: 2,
                    )
                  ]).then((value) async {
                if (value == 1) {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AddTaskPage(currentTask: todoList[index])
                  ));
                  await updateTodoList(_currentDate!);
                  setState((){});
                } else if (value == 2) {
                  await DatabaseHelper().deleteTask(todoList[index].id!);
                  Noti().cancelNotification(todoList[index].id!);
                  setState(() {
                    todoList.removeAt(index);
                  });
                }
              });
            },
            child: Card(
              child: InkWell(
                onTap: (){},
                child: ListTile(
                title: Text(todoList[index].description ?? ''),
                subtitle: Text('${todoList[index].time!.hour.toString().padLeft(2, '0')}:'
                    '${todoList[index].time!.minute.toString().padLeft(2, '0')}'),
                trailing: todoList[index].imagePath != null && File(todoList[index].imagePath!).existsSync()
                    ? Image.file(File(todoList[index]!.imagePath!), height: 50, width: 50,)
                    : null,),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) => AddTaskPage.newEl(date: _currentDate!)
          ));
          await updateTodoList(_currentDate!);
          setState((){});
        },
        child: Icon(Icons.add_box, color: Colors.greenAccent),
      ),
    );
  }
}
