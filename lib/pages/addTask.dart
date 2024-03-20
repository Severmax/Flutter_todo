import 'package:flutter/material.dart';
import 'package:flutter_todo/logic/databaseHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_todo/logic/Task.dart';
import 'package:flutter_todo/logic/localNotifications.dart';

class AddTaskPage extends StatefulWidget {
  final Task currentTask;

   AddTaskPage({Key? key, required this.currentTask}) : super(key: key,);
   AddTaskPage.newEl({Key? key, required DateTime date}) : currentTask = Task("","", date, TimeOfDay.now()),
        super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late Task? _currentTask;
  late TimeOfDay? _selectedTime;
  late List<bool> _selectedColors;
  List<Color?> _enabledColors = [
    Colors.white, Colors.indigo, Colors.green, Colors.deepOrangeAccent,
    Colors.amberAccent, Colors.tealAccent,
  ];


  @override
  void initState() {
    super.initState();
    _currentTask = widget.currentTask;
    _selectedTime = _currentTask!.time!;
    _selectedColors = List.filled(6, false);

    for (int i = 0; i<_enabledColors.length; i++){
      if (_currentTask!.colorD.containsKey(_currentTask!.color)){
        if (_enabledColors[i] == _currentTask!.colorD[_currentTask!.color]){
          _selectedColors[i] = true;
          break;
        }
      }
    }
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(//Заголовок..............................................
              margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                controller: TextEditingController(text: this._currentTask!.heading),
                onChanged: (String value) =>this._currentTask!.heading = value,
                decoration:
                InputDecoration(
                  hintText: 'Заголовок',
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
                minLines: 1,
              ),
            ),
            Container(//текст задачі(Опис)..............................................
              margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                controller: TextEditingController(text: this._currentTask!.description),
                onChanged: (String value) =>this._currentTask!.description = value,
                decoration:
                InputDecoration(
                  hintText: 'Опишіть вашу задачу...',
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
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Колір:",
                  style: TextStyle(fontSize: 30.0, color: Colors.white),
                ),
                ToggleButtons(
                  children: [
                    Icon(Icons.square, color: _enabledColors[0], size: 30,),
                    Icon(Icons.square, color: _enabledColors[1], size: 30,),
                    Icon(Icons.square, color: _enabledColors[2], size: 30,),
                    Icon(Icons.square, color: _enabledColors[3], size: 30,),
                    Icon(Icons.square, color: _enabledColors[4], size: 30,),
                    Icon(Icons.square, color: _enabledColors[5], size: 30,),
                  ],
                  isSelected:  _selectedColors, // Початковий стан вибраних кнопок
                  onPressed: (index) {
                    setState(() {
                      for (var i = 0; i < _selectedColors.length; i++) {
                        _selectedColors[i] = false;
                      }
                      _selectedColors[index] = !_selectedColors[index];
                      _currentTask!.color = _currentTask!.getKeyByValue(_enabledColors[index])!;
                      print(_currentTask!.color);
                    });
                  },
                  color: Colors.white, // Колір обводки кнопок
                  selectedColor: Colors.white, // Колір тексту на вибраних кнопках
                  fillColor: Colors.grey, // Колір фону кнопок
                  borderWidth: 2, // Товщина обводки кнопок
                  selectedBorderColor: Colors.white, // Колір обводки вибраних кнопок
                  renderBorder: true, // Показувати обводку кнопок
                  constraints: BoxConstraints.tightFor(width: 30, height: 30),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}