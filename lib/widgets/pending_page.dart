import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/model/todo_model.dart';
import 'package:todo_app/services/database_services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:appwrite/appwrite.dart';
import 'package:uuid/uuid.dart';
class PendingWidget extends StatefulWidget {
  const PendingWidget({super.key});

  @override
  State<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends State<PendingWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;
  final client = Client()..setEndpoint('https://cloud.appwrite.io/v1')..setProject('67ac4a9c0034d48fa129');
  late Storage storage;
  var inputFile;


  final DatabaseServices _databaseServices = DatabaseServices();

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    storage = Storage(client);
    if (currentUser != null) {
      uid = currentUser.uid;
    } else {
      print("Ошибка: Пользователь не авторизован");
    }
  }




Future<void> upLoadPhoto(String? id, dynamic inputFile) async {
  try {
    if (id == null || inputFile == null || storage == null) {
      print("Ошибка: не все необходимые параметры инициализированы.");
      return;
    }

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("Нет подключения к интернету. Загрузка изображения пропущена.");
      return;
    }

    await storage.createFile(
      bucketId: '678a2da0001c315f64f4',
      fileId: id,
      file: inputFile,
    );

    print("Изображение успешно загружено.");
  } catch (e) {
    print("Ошибка при загрузке изображения: ${e.toString()}");
  }
}


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _databaseServices.todos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text("Ошибка при загрузке данных"),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<Todo> todos =
              snapshot.data!.where((todo) => todo.completed == false).toList();
          return SizedBox(
            height: todos.length * 85,
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                Todo todo = todos[index];
                final DateTime dt = DateTime.now();
                // final DateTime dt = todo.timestamp?.toDate() ?? DateTime.now();
                // final DateTime dt = todo.timestamp != null ? todo.timestamp!.toDate() : DateTime.now();
                // final DateTime dt = todo.timestamp.toDate();
                 String formattedDeadline = todo.deadline == null
                    ? 'No deadline set'
                    : '${todo.deadline!.toDate().day}/${todo.deadline!.toDate().month}/${todo.deadline!.toDate().year}';
                return Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF1d2630)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: DrawerMotion(),
                      children: [
                        SlidableAction(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          label: 'Mark',
                          icon: Icons.done,
                          onPressed: (context) {
                            _databaseServices.updateTodoStatus(todo.id, true);
                          },
                        )
                      ],
                    ),
                    startActionPane:
                        ActionPane(motion: DrawerMotion(), children: [
                      SlidableAction(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                          onPressed: (context) {
                            _showTaskDialog(context, inputFile, storage);
                          }),
                      SlidableAction(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                          onPressed: (context) async {
                            await _databaseServices.deleteTodoTask(todo.id);
                          })
                    ]),
                    key: ValueKey(todo.id),
                    child: ListTile(
                      leading: ClipRRect(
                        child: Image.network("https://cloud.appwrite.io/v1/storage/buckets/67ac4bb2003a4dfc8922/files/${todo.imageUrl}/view?project=67ac4a9c0034d48fa129&mode=admin"),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                      ),
                      subtitle: Text(
                        todo.description,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                      ),
                      trailing: Text(
                        'Deadline: ${formattedDeadline}',
                        // '${dt.day}/${dt.month}/${dt.year}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                      ),
                    ),  
                  ),
                );
              },
            ),
          );
        } else {
          return Center(
            child: Text("Нет данных для отображения"),
          );
        }
      },
    );
  }
}

void _showTaskDialog(BuildContext context, inputFile, storage,{Todo? todo}) {
  final TextEditingController _titleController =
      TextEditingController(text: todo?.title);
  final TextEditingController _descriptionController =
      TextEditingController(text: todo?.description);
  final DatabaseServices _databaseService = DatabaseServices();
  Timestamp? selectedDeadline = todo?.deadline;
    final id  = Uuid().v4();
  var selectedImage;


  Future<void> upLoadPhoto(id, inputFile, storage) async {
    try {
      if (id == null || inputFile == null || storage == null) {
        print("Ошибка: не все необходимые параметры инициализированы.");
        return;
      }
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        print("Нет подключения к интернету. Загрузка изображения пропущена.");
        return;
      }

      final fileId = id;
      await storage.createFile(
        bucketId: '67ac4bb2003a4dfc8922',
        fileId: fileId,
        file: inputFile,
      );
      print("Изображение успешно загружено.");
    } catch (e) {
      print("Ошибка при загрузке изображения: $e");
}}


  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            todo == null ? "Add Task" : "Edit Task",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'asd',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),

                  ListTile(
                    title: Text(selectedDeadline == null
                        ? 'Selected'
                        : 'Deadline: ${selectedDeadline!.toDate().day}/${selectedDeadline!.toDate().month}/${selectedDeadline!.toDate().year}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(2100));
                      if (pickedDate != null) {
                        selectedDeadline = Timestamp.fromDate(pickedDate);
                      }
                    },
                  ),


                  
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel')),
            TextButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  if (todo == null) {
                    await _databaseService.addTodoItem(
                      _titleController.text,
                      _descriptionController.text,
                      selectedDeadline ?? Timestamp.fromDate(DateTime.now()),
                      id
                      
                    );

                      if (selectedImage != null) {
                        inputFile = InputFile.fromPath(path: selectedImage.path);
                        await upLoadPhoto(id, inputFile, storage);
                        }
                  } else {
                    await _databaseService.updateTodo(
                      todo.id,
                      _titleController.text,
                      _descriptionController.text,
                      selectedDeadline ?? Timestamp.fromDate(DateTime.now()),
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(todo == null ? "Add" : "Update")),
          ],
        );
      });
}

class ImageHelper {
  static Future<XFile> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) {
      throw Exception("No file selected");
    }
    return pickedFile;
  }

  static Future<File?> loadImage() async {
    try {
      final pickedFile = await pickImage(ImageSource.gallery);
      return File(pickedFile.path);
    } catch (e) {
      print("Error selecting image: $e");
      return null;
    }
  }
}