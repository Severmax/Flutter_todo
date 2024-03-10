import 'package:flutter/material.dart';
import 'package:flutter_todo/logic/databaseHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_todo/logic/Task.dart';
import 'package:flutter_todo/logic/localNotifications.dart';

class AddTaskPage extends StatefulWidget {
  final Task currentTask;

   AddTaskPage({Key? key, required this.currentTask}) : super(key: key,);
   AddTaskPage.newEl({Key? key, required DateTime date}) : currentTask = Task("", date, TimeOfDay.now()),
        super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late Task? _currentTask;
  late TimeOfDay? _selectedTime;


  @override
  void initState() {
    super.initState();
    _currentTask = widget.currentTask;
    _selectedTime = _currentTask!.time!;
  }

  File? _imageFile;

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      this._currentTask!.imagePath = _imageFile!.path;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: this._selectedTime!,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
      this._currentTask!.time = _selectedTime;
    }
  }

  @override
   Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Редагування завдання'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
              onPressed: () async {
                if (this._currentTask!.id != null) {
                  await DatabaseHelper().updateTask(this._currentTask!.toMap(context));
                }
                else {
                  await DatabaseHelper().addTask(this._currentTask!.toMap(context));
                  Map<String, dynamic>? lastInsertedTaskMap = await DatabaseHelper().getLastInsertedTask();
                  if (lastInsertedTaskMap != null) {
                    this._currentTask = Task.fromMap(lastInsertedTaskMap);
                  }
                }
                Noti().setNotification(_currentTask!);
                Navigator.pop(context, true);
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(//текст задачі..............................................
              margin: EdgeInsets.all(20),
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                controller: TextEditingController(text: this._currentTask!.description),
                onChanged: (String value) =>this._currentTask!.description = value,
                decoration:
                  InputDecoration(
                  hintText: 'Введіть вашу задачу...',
                  hintStyle: TextStyle(color: Colors.white24),
                  fillColor: Colors.black38,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                    ),
                   focusedBorder: OutlineInputBorder(
                     borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
                     borderRadius: BorderRadius.circular(10.0),
                   ),
                  ),
                minLines: 3,
                maxLines: 4,
              ),
            ),
            Row( //ряд зображення та часу...................................................
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Зображення:',
                        style: TextStyle(fontSize: 14.0, color: Colors.white),
                      ),
                      Text(
                          "(Не обов'язково)",
                          style: TextStyle(fontSize: 14.0, color: Colors.white)
                      ),
                      if (_currentTask!.imagePath != null && File(_currentTask!.imagePath!).existsSync())
                        Image.file(File(_currentTask!.imagePath!), height: 100, width: 100)
                      else
                        Icon(Icons.image, size: 100, color: Colors.white),
                      SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: _captureImage,
                          child: Text("Завантажити"))
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Час:',
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 30.0, color: Colors.white),
                      ),
                      SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: () => _selectTime(context),
                        child: Text('Змінити'),

                      ),
                    ],
                  ),
                ]
            ),
          ],
      ),
    );
  }
}