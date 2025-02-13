import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app/model/todo_model.dart';

class DatabaseServices {
  final CollectionReference todoCollection =
      FirebaseFirestore.instance.collection("todos");

  User? user = FirebaseAuth.instance.currentUser;

  Future<DocumentReference> addTodoItem(
      String title, String description, Timestamp deadline, url) async {
    return await todoCollection.add({
      "uid": user!.uid,
      'title': title,
      'description': description,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'deadline': deadline,
      "url": url
    });
  }

  Future<void> updateTodo(
      String id, String title, String description, Timestamp deadline) async {
    final updatetodoCollection =
        FirebaseFirestore.instance.collection("todos").doc(id);
    return await updatetodoCollection.update(
        {'title': title, 'description': description, 'deadline': deadline});
  }

  Future<void> updateTodoStatus(String id, bool completed) async {
    return await todoCollection.doc(id).update({"completed": completed});
  }

  Future<void> deleteTodoTask(String id) async {
    return await todoCollection.doc(id).delete();
  }

  Stream<List<Todo>> get todos {
    return todoCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed')
        .snapshots()
        .map(_todoListFromSnapshots);
  }

  Stream<List<Todo>> get completedtodos {
    return todoCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map(_todoListFromSnapshots);
  }

  List<Todo> _todoListFromSnapshots(QuerySnapshot snapshots) {
    return snapshots.docs.map((doc) {
      return Todo(
        id: doc.id,
        title: doc['title'],
        description: doc['description'],
        completed: doc['completed'],
        // timestamp:
        //     doc['createdAt'] != null ? doc['createdAt'] as Timestamp : null
        timestamp: doc['createdAt'],
        deadline: doc['deadline'],
        imageUrl: doc["url"]
      );
    }).toList();
  }
}
