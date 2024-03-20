import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Task{
  int? id;
  String? heading;
  String? description;
  String? imagePath;
  DateTime? date;
  TimeOfDay? time;
  String color;
  bool done;

  Map<String, Color?> colorD= {
    "Білий" : Colors.white,
    "Фіолетовий" : Colors.indigo,
    "Зелений" : Colors.green,
    "Помаранчевий" : Colors.deepOrangeAccent,
    "Жовтий" : Colors.amberAccent,
    "Голубий" : Colors.tealAccent,
  };

  Task( this.heading ,this.description, this.date, this.time, [this.id, this.imagePath, this.color = "Білий", this.done = false]);

  Map<String, dynamic> toMap(BuildContext context) {
    return {
      'id': id,
      'imagePath': imagePath,
      'heading': heading,
      'description': description,
      'date': DateFormat('yyyy-MM-dd').format(date!),
      'time': time?.format(context),
      'color': color,
      'done': done ? 1 : 0,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      map['heading'],
      map['description'],
      DateFormat('yyyy-MM-dd').parse(map['date']),
      _timeParse(map['time']),
      map['id'],
      map['imagePath'],
      map['color'],
      map['done'] == 1 ? true : false
    );
  }

  static TimeOfDay _timeParse(String timeString){
    List<String> parts = timeString.split(':');

    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    TimeOfDay timeOfDay = TimeOfDay(hour: hours, minute: minutes);
    return timeOfDay;
  }

  String? getKeyByValue(var value) {
    for (var entry in colorD.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return null; // Якщо значення не знайдено
  }
}
