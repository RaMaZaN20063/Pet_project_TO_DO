import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/model/todo_model.dart';
import 'package:todo_app/services/database_services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CompletedWidget extends StatefulWidget {
  const CompletedWidget({super.key});

  @override
  State<CompletedWidget> createState() => _CompletedWidgetState();
}

class _CompletedWidgetState extends State<CompletedWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;
  final DatabaseServices _databaseServices = DatabaseServices();

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
    } else {
      print("Ошибка: Пользователь не авторизован");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _databaseServices.completedtodos,
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
          List<Todo> todos = snapshot.data!;
          return SizedBox(
            height: todos.length * 85,  
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                Todo todo = todos[index];
                // final DateTime dt = todo.timestamp.toDate();
                return Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Slidable(
                    endActionPane:
                        ActionPane(motion: DrawerMotion(), children: [
                      SlidableAction(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          label: 'Delete',
                          icon: Icons.delete,
                          onPressed: (context) async {
                            await _databaseServices.deleteTodoTask(todo.id);
                          })
                    ]),
                    startActionPane: ActionPane(motion: DrawerMotion(), children: [
                      SlidableAction(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        label: 'Not Completed',
                        icon: Icons.edit,
                        onPressed: (context) {
                          _databaseServices.updateTodoStatus(todo.id, false);
                        })
                    ]),
                    key: ValueKey(todo.id),
                    child: ListTile(
                      title: Text(
                        todo.title,
                        style: const TextStyle(fontWeight: FontWeight.w500, decoration: TextDecoration.lineThrough),
                      ),
                      subtitle: Text(
                        todo.description,
                        style: const TextStyle(fontWeight: FontWeight.w500, decoration: TextDecoration.lineThrough),
                      ),
                      trailing: Text(
                        '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

