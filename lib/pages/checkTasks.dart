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

  Color? colorSet(Task task){
    DateTime today = DateTime.now();
    DateTime dayOfTask = DateTime(task.date!.year, task.date!.month, task.date!.day, task.time!.hour,task.time!.minute);
    if (task.done){
      return Colors.grey;
    }
    else if (!task.done && dayOfTask.isBefore(today)){
      return Color.fromARGB(255, 150, 6, 6);
    }
    else {
      return task.colorD[task.color];
    }
  }

  Text headingSet(Task task){
    DateTime today = DateTime.now();
    DateTime dayOfTask = DateTime(task.date!.year, task.date!.month, task.date!.day, task.time!.hour,task.time!.minute);
    if (!task.done && dayOfTask.isBefore(today)){
      return Text("${task.heading}(Прострочено)" ?? "(Прострочено)");
    }
    else {
      return Text(task.heading ?? "");
    }
  }

  Future<void> updateTodoList(DateTime date) async {
    List<Map<String, dynamic>> tasksMap = await DatabaseHelper().getTasksForDay(date, false);
    List<Task> tasks = tasksMap.map((taskMap) => Task.fromMap(taskMap)).toList();

    var completedTasksMap = await  DatabaseHelper().getTasksForDay(date, true);
    List<Task> completedTasks = completedTasksMap.map((completedTasksMap) => Task.fromMap(completedTasksMap)).toList();

    tasks.sort((a, b) {
      int hourComparison = a.time!.hour - b.time!.hour;
      if (hourComparison != 0) {
        return hourComparison;
      }
      return a.time!.minute - b.time!.minute;
    });

    setState(() {
      todoList = tasks;
      todoList.addAll(completedTasks);
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
              color:  colorSet(todoList[index]),
              child: InkWell(
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: headingSet(todoList[index]),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(todoList[index].description ?? ""),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Закриття діалогового вікна
                            },
                            child: Text('Закрити'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: ListTile(
                  title: headingSet(todoList[index]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20, // Встановлюємо висоту для обмеження рядків
                        child: Text(
                          todoList[index].description ?? '',
                          maxLines: 1, // Встановлюємо максимальну кількість рядків
                          overflow: TextOverflow.ellipsis, // Обрізаємо текст, який виходить за межі
                        ),
                      ),
                      Text(
                        '${todoList[index].time!.hour.toString().padLeft(2, '0')}:'
                            '${todoList[index].time!.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      todoList[index].imagePath != null && File(todoList[index].imagePath!).existsSync()
                          ? Image.file(File(todoList[index].imagePath!), height: 50, width: 50,)
                          : SizedBox(), // Зображення, якщо воно існує
                      SizedBox(width: 10), // Проміжок між зображенням та селект кнопкою
                      Checkbox(
                        value: todoList[index].done ?? false, // Стан селект кнопки
                        onChanged: (value) {
                          setState(() {
                            todoList[index].done = !todoList[index].done; // Зміна стану селект кнопки
                            DatabaseHelper().updateTask(todoList[index].toMap(context));
                            updateTodoList(_currentDate!);
                            print(todoList[index].done);
                          });
                        },
                      ),
                    ],
                  ),
                ),
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
