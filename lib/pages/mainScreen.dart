import 'package:flutter/material.dart';
import 'package:flutter_todo/pages/checkTasks.dart';
import 'package:flutter_todo/logic/databaseHelper.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter_todo/logic/localNotifications.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});


  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime today = DateTime.now();
  Map<String, dynamic> _markedDatesMap = {};


  @override
  Widget build (BuildContext context){


    return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: Text("Календар"),
          centerTitle: true,
          ),
        body: Calendar(),
      );
  }

  Future<void> setNotification() async{
    await Noti().initNotifications();
    await Noti().setDeiliNotification();
  }

  Future<void> MarkedDatesUpdate() async{
      List<DateTime> _markedDates = await DatabaseHelper().getDaysWithTasks();
      _markedDatesMap = {};
      for (var date in _markedDates) {
        setState(() {
          _markedDatesMap['${date.year}.${date.month}.${date.day}'] = TextStyle(color: Colors.pink);
        });
      }

  }

  @override
  void initState() {
    super.initState();
    setNotification();
    MarkedDatesUpdate();
  }

  Widget Calendar() {
    return Column(
      children: [
        Container(
          child: TableCalendar(
            calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final isFocusedDay = isSameDay(date, today);
                  final style = _markedDatesMap['${date.year}.${date.month}.${date.day}'];

                  if (style != null && !isFocusedDay) {
                    return Center(
                      child: Text(
                        '${date.day}',
                        style: style,
                      ),
                    );
                  } else if (style != null && isFocusedDay) {
                    return Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  } else if (style == null && isFocusedDay) {
                    return Center(
                        child: Text(
                        '${date.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return null;
                }
            ),
            headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.white),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
            onDaySelected: (selectedDay, focusedDay) async {
              await Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CheckTasks(currentDate: selectedDay))
              );
              await MarkedDatesUpdate();
              setState(() {});
            },
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2040, 1, 1),
            focusedDay: today,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
              weekdayStyle: TextStyle(color: Colors.blue),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(color: Colors.white),
              outsideTextStyle: TextStyle(color: Colors.grey),
              weekendTextStyle: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}


