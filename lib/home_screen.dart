import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:todo_app/screens/login_screen.dart';
import 'package:todo_app/model/todo_model.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/services/database_services.dart';
import 'package:todo_app/widgets/completed_page.dart';
import 'package:todo_app/widgets/pending_page.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isexit = false;
  var inputFile;
  late Storage storage;
  final client = Client()..setEndpoint('https://cloud.appwrite.io/v1')..setProject('67ac4a9c0034d48fa129');



  @override
  void initState() {
    super.initState();
    storage = Storage(client);
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  void _addListenerForNavigation() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  int _buttonindex = 0;
  final widgets = [
    //pending Task Widget
    PendingWidget(),
    //completed Task Widget
    CompletedWidget(),
  ];
  @override
  Widget build(BuildContext context) {
    return _isexit == false
        ? Scaffold(
            appBar: AppBar(
              title: Text('To Do'),
              actions: [
                IconButton(
                    onPressed: () async {
                      setState(() {
                        _isexit = true;
                      });
                      await AuthService().singOut();
                      _addListenerForNavigation();
                      _controller.forward();
                    },
                    icon: Icon(Icons.exit_to_app))
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            _buttonindex = 0;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2.2,
                          decoration: BoxDecoration(
                              color: _buttonindex == 0
                                  ? Colors.indigo
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              'Pending',
                              style: TextStyle(
                                  fontSize: _buttonindex == 0 ? 16 : 14,
                                  fontWeight: _buttonindex == 0
                                      ? FontWeight.bold
                                      : FontWeight.w100,
                                  color: _buttonindex == 0
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            _buttonindex = 1;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2.2,
                          decoration: BoxDecoration(
                              color: _buttonindex == 1
                                  ? Colors.indigo
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _buttonindex == 1
                                      ? FontWeight.bold
                                      : FontWeight.w100,
                                  color: _buttonindex == 1
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30),
                  widgets[_buttonindex]
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF1d2630)
                    : Colors.white,
                child: Icon(Icons.add),
                onPressed: () {
                  _showTaskDialog(context, inputFile, storage);
                }),
          )
        : Container(
            color: Color(0xFF1d2630),
            child: Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_Cc8Bpg.json'));
  }
}

void _showTaskDialog(BuildContext context, inputFile, storage, {Todo? todo}) {
  final TextEditingController _titleController =
      TextEditingController(text: todo?.title);
  final TextEditingController _descriptionController =
      TextEditingController(text: todo?.description);
  final DatabaseServices _databaseService = DatabaseServices();
  Timestamp? selectedDeadline = todo?.deadline;
  var selectedImage;
  final id  = Uuid().v4();

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
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Color(0xFF1d2630)
                : Colors.white,
            title: Text(
              todo == null ? "Add Task" : "Edit Task",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text(selectedDeadline == null
                        ? "Select Deadline"
                        : "Deadline: ${selectedDeadline!.toDate().day}/${selectedDeadline!.toDate().month}/${selectedDeadline!.toDate().year}"),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        selectedDeadline = Timestamp.fromDate(pickedDate);
                        setState(() {}); 
                      }
                    },
                  ),

                  IconButton(
                    onPressed: () async{
     selectedImage = await ImageHelper.loadImage();  
                    }, 
                  icon: Icon(Icons.image))
                ],
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
      });
}
