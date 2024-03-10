import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Task{
  int? id;
  String? imagePath;
  String? description;
  DateTime? date;
  TimeOfDay? time;

  Task( this.description, this.date, this.time, [this.id, this.imagePath]);

  Map<String, dynamic> toMap(BuildContext context) {
    return {
      'id': id,
      'imagePath': imagePath,
      'description': description,
      'date': DateFormat('yyyy-MM-dd').format(date!),
      'time': time?.format(context),
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      map['description'],
      DateFormat('yyyy-MM-dd').parse(map['date']),
      _timeParse(map['time']),
      map['id'],
      map['imagePath'],
    );
  }

  static TimeOfDay _timeParse(String timeString){
    List<String> parts = timeString.split(':');

    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    TimeOfDay timeOfDay = TimeOfDay(hour: hours, minute: minutes);
    return timeOfDay;
  }
}
